extends CanvasLayer

@onready var health_label = $HealthLabel


func _ready():
	# Only show UI for the local player
	var player = get_parent() as CharacterBody3D
	if not player or not player.is_multiplayer_authority():
		queue_free()
		return
	
	# Set label text color to white
	health_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Set label background to green
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color.GREEN
	panel_style.set_corner_radius_all(5)
	panel_style.set_content_margin_all(10)
	health_label.add_theme_stylebox_override("normal", panel_style)
	
	connect_to_local_player()


func connect_to_local_player():
	var player = get_parent() as CharacterBody3D
	if player and player.is_multiplayer_authority():
		print("Connected to player:", player.name)  # debug
		
		player.health_changed.connect(_on_health_changed)
		
		# Set initial value
		health_label.text = str(player.health) + " / 100"


func _on_health_changed(new_health):
	print("Health updated:", new_health)  # debugs
	health_label.text = str(new_health) + " / 100"
