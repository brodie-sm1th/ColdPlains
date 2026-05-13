extends CharacterBody3D

signal health_changed(health_value)

@onready var collision_shape = $CollisionShape3D
@export var camera : Camera3D
@export var anim_player : AnimationPlayer
@export var muzzle_flash : GPUParticles3D
@export var raycast : RayCast3D
@export var flashlight : Node3D
@export var enemy_raycast : RayCast3D
@export var particle_raycast : RayCast3D
@export var walk_speed: float = 5.0
@export var slide_speed: float = 20.0
@export var slide_duration: float = 0.5
@export var slide_friction: float = 0.95
@export var no_cooldown = false

var hit_explosion_scene = preload("res://Shaders/hit_explosion.tscn")

var is_sliding: bool = false
var slide_timer: float = 0.0
var is_dead: bool = false
#var player_id: int 

var health = 100
var damage = 3

var SPEED = 10.0
var JUMP_VELOCITY = 10.0
const LOOK_SPEED = 5 # Adjust as needed for controller comfort

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

var crouch_height = 0.5
var stand_height = 2.0
var is_crouched = false
var crouch_speed = 3
var crouch_jump_velocity = 3
const CROUCH_TRANSLATE = 0.7

func _enter_tree():
	print(name)
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	# Hide health bar UI for other players
	$CanvasLayer.visible = true

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	if not is_multiplayer_authority() or is_dead: 
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_pressed("shoot") \
			and not is_dead \
			and (anim_player.current_animation != "shoot" or no_cooldown):
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
		if enemy_raycast.is_colliding():
			enemy_raycast.get_collider().damage_taken += damage #replace with signals later
		if particle_raycast.is_colliding():
			var hit_explosion = hit_explosion_scene.instantiate()
			var pos = particle_raycast.get_collision_point()
			var norm = particle_raycast.get_collision_normal()
			hit_explosion.look_at_from_position(pos, norm + pos)
			get_parent().add_child(hit_explosion)
	
	if Input.is_action_just_pressed("capture_toggle") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("capture_toggle"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	if not is_multiplayer_authority() or is_dead: 
		return
	
	_handle_crouch(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	# Handle Jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity += JUMP_VELOCITY * get_floor_normal()
		
	#Toggle Flashlight 
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight.visible = not flashlight.visible

	# Handle slide input
	if Input.is_action_just_pressed("slide") and is_on_floor():
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction != Vector3.ZERO and not is_sliding:
			start_slide(direction)

	# Update slide
	if is_sliding:
		slide_timer += delta
		velocity.x *= slide_friction
		velocity.z *= slide_friction
		if slide_timer >= slide_duration:
			is_sliding = false
	else:
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			var damping_value = 10 # Number of frames before horizontal velocity is reduced to 0. Replace later with a more inclusive system
			velocity.x = move_toward(velocity.x, 0, SPEED / damping_value * abs(velocity.normalized().x))
			velocity.z = move_toward(velocity.z, 0, SPEED / damping_value * abs(velocity.normalized().z))

	# --- New: Handle Camera Look (Right Stick) ---
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	if look_dir != Vector2.ZERO:
		rotate_y(-look_dir.x * LOOK_SPEED * delta)
		camera.rotate_x(-look_dir.y * LOOK_SPEED * delta)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	if anim_player.current_animation == "shoot":
		pass
	elif Input.get_vector("left", "right", "up", "down") != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")

func start_slide(direction: Vector3) -> void:
	is_sliding = true
	slide_timer = 0.0
	velocity.x = direction.x * slide_speed
	velocity.z = direction.z * slide_speed

@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer", "call_local")
func receive_damage():
	if is_dead:
		return

	health -= damage
	health_changed.emit(health)
	
	if health <= 0:
		rpc("die")

func _handle_crouch(delta) -> void:
	if is_crouched: 
		SPEED = crouch_speed 
		JUMP_VELOCITY = crouch_jump_velocity
	else: 
		SPEED = 10
		JUMP_VELOCITY = 10
	
	is_crouched = Input.is_action_pressed("crouch")
	camera.position = Vector3(0,(CROUCH_TRANSLATE if is_crouched else 1.513),0)
	$CollisionShape3D.shape.height = stand_height - CROUCH_TRANSLATE if is_crouched else stand_height
	$CollisionShape3D.position.y = $CollisionShape3D.shape.height / 2


@rpc("authority", "call_local")
func die():
	if is_dead:
		return
	velocity = Vector3.ZERO
	set_process(false)
	set_physics_process(false)
	hide()
	$CollisionShape3D.disabled = true
	
	if is_multiplayer_authority():
		get_tree().call_group("ui","show_lose_screen")
