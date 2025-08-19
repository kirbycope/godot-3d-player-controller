extends Node3D

const SWIMMING_SOUND = preload("res://assets/sounds/pool/398037__swordofkings128__water-swimming-1_2.mp3")

var player: CharacterBody3D

@onready var area_3d: Area3D = $Area3D


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if there is a player reference
	if player != null:
		# Check if the player is moving
		if player.velocity != Vector3.ZERO:
			# Check if the audio player is not playing or the stream is not the swimming sound
			if !player.audio_player.playing or player.audio_player.stream != SWIMMING_SOUND:
				# Set the audio player's stream to the "swimming" sound effect
				player.audio_player.stream = SWIMMING_SOUND
				# Play the "swimming" sound effect
				player.audio_player.play()


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if the collision body is a character
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Save a reference to the player
		player = body
		# Drop any equipment before swimming
		body.reparent_held_item()
		# Store which body the player is swimming in
		body.is_swimming_in = area_3d
		# Get the string name of the player's current state
		var current_state = body.base_state.get_state_name(body.current_state)
		# Start "swimming"
		body.base_state.transition(current_state, "Swimming")


## Called when a Node3D exits the Area3D.
func _on_area_3d_body_exited(body: Node3D) -> void:
	# Check if the collision body is a character
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Clear the referecne to the pool
		player.is_swimming_in = null
		# Clear the reference to the player
		player = null
		# Stop "swimming"
		body.base_state.transition("Swimming", "Standing")
