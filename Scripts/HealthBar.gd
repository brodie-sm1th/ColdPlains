extends CanvasLayer

@onready var health_bar = $Healthbar
@onready var health_label = $Healthbar/HealthLabel


func _ready():
	# Configure the progress bar to show health 0-100
	health_bar.min_value = 0
	health_bar.max_value = 100
	health_bar.value = 100
	
	connect_to_local_player()
	
	# Configure the progress bar to show health 0-100
	health_bar.min_value = 0
	health_bar.max_value = 100
	health_bar.value = 100
	
	# Set bar colors directly
	health_bar.self_modulate = Color.GREEN  # Makes the bar green
	
	connect_to_local_player()


func connect_to_local_player():
	# Loop through all players
	for player in get_tree().get_nodes_in_group("players"):
		
		# Only connect to YOUR player
		if player.is_multiplayer_authority():
			
			print("Connected to player:", player.name)  # debug
			
			player.health_changed.connect(_on_health_changed)
			
			# Set initial value
			health_bar.value = player.health
			health_label.text = str(player.health) + " / 100"

func _on_health_changed(new_health):
	print("Health updated:", new_health)  # debug
	health_bar.value = new_health
	health_label.text = str(new_health) + " / 100"
