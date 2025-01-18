extends Node3D

@onready var player: CharacterBody3D = $Player

## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Disable the mouse pointer and capture the motion
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Make sure the game is unpaused
	player.game_paused = false
	
	$"PortalGun/AnimationPlayer".play("rotate")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		pick_up_portal_gun()

func pick_up_portal_gun() -> void:

		$Player.is_holding_rifle = true
		$PortalGun.queue_free()

		# Load the scene
		var scene = load("res://scenes/portal_gun.tscn")

		# Instantiate the scene
		var instance = scene.instantiate()

		# Add the instance to the player scene
		$"Player/Visuals/HeldItemMount".add_child(instance)
