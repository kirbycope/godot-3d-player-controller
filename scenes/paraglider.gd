extends Node3D

var player: CharacterBody3D

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if the player is not null
	if player != null:
		# Check if the player is not paragliding
		if !player.is_paragliding:
			# Hide the paraglider
			hide()
		# The player must not be paragliding
		else:
			# hide the paraglider
			show()


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Reparent any head items
		body.reparent_equipped_head_items()
		# Load the scene
		var scene = load("res://scenes/paraglider.tscn")
		# Instantiate the scene
		var instance = scene.instantiate()
		# Set the player reference for the new skateboard instance
		instance.player = body
		# Disable the "pickup" collision
		instance.get_node("Area3D/CollisionShape3D").disabled = true
		# Add the instance to the player scene
		body.head_mount.add_child(instance)
		# [Hack] Adjust visuals (to align with `y_bot.tscn`)
		instance.rotation.y = deg_to_rad(180)
		instance.position.y -= 0.4
		instance.position.z -= 0.2
		# Remove _this_ instance
		queue_free()
		# Get the string name of the player's current state
		var current_state = body.base_state.get_state_name(body.current_state)
		# Start "paragliding"
		body.base_state.transition(current_state, "Paragliding")
