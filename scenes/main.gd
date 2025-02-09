extends Node3D

@onready var player: CharacterBody3D = $Player


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Disable the mouse pointer and capture the motion
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Make sure the game is unpaused
	player.game_paused = false

	# Rotate the Portal gun
	$"PortalGun/AnimationPlayer".play("rotate")


func _on_area_3d_fishing_rod_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		pick_up_fishing_rod()


func _on_area_3d_portal_gun_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		pick_up_portal_gun()


func _on_area_3d_2_body_entered(body: Node3D) -> void:
		if body is CharacterBody3D:
			pick_up_skateboard()


func pick_up_fishing_rod() -> void:

	$Player.is_holding_fishing_rod = true
	$FishingRod.queue_free()

	# Load the scene
	var scene = load("res://scenes/fishing_rod.tscn")

	# Instantiate the scene
	var instance = scene.instantiate()

	# Add the instance to the player scene
	$"Player/Visuals/HeldItemMount".add_child(instance)


func pick_up_portal_gun() -> void:

	$Player.is_holding_rifle = true
	$PortalGun.queue_free()

	# Load the scene
	var scene = load("res://scenes/portal_gun.tscn")

	# Instantiate the scene
	var instance = scene.instantiate()

	# Add the instance to the player scene
	$"Player/Visuals/HeldItemMount".add_child(instance)


func pick_up_skateboard() -> void:

	$Skateboard.queue_free()

	# Load the scene
	var scene = load("res://scenes/skateboard.tscn")

	# Instantiate the scene
	var instance = scene.instantiate()

	# Add the instance to the player scene
	$"Player/Visuals/SkateboardMount".add_child(instance)

	# Get the string name of the player's current state
	var current_state = player.base_state.get_state_name(player.current_state)

	# Start "skateboarding"
	player.base_state.transition(current_state, "Skateboarding")
