extends Node3D

var player: CharacterBody3D
var stored_horizontal_velocity: Vector3 = Vector3.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var ollie_land_sound = preload("res://assets/skateboard/LandConc.wav") as AudioStream
@onready var ollie_start_sound = preload("res://assets/skateboard/OllieConc.wav") as AudioStream
@onready var skateboarding_sound = preload("res://assets/skateboard/RollConcSmooth.wav") as AudioStream


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the player is not null
	if player:
		# Check if the game is not paused
		if !player.game_paused:
			# Ⓐ/[Space] button just _pressed_
			if event.is_action_pressed("button_0"):
				# Check if the player is on the ground
				if player.is_on_floor():
					# Store the current horizontal velocity for momentum
					stored_horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)

					# Set the audio player's stream to the "ollie start" sound effect
					audio_player.stream = ollie_start_sound

					# Play the sound effect
					audio_player.play()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if the player is not null
	if player != null:
		# Check if the player is on the ground and flagged as "jumping"
		if player.velocity.y == 0 and player.is_jumping:
			# Flag the player as not "jumping"
			player.is_jumping = false

			# Set the audio player's stream to the "ollie land" sound effect
			audio_player.stream = ollie_land_sound

			# Play the sound effect
			audio_player.play()

		# Check if the player is moving
		if player.velocity != Vector3.ZERO:
			# Check if the player is grounded
			if player.velocity.y == 0:
				# Check if the player is slower than or equal to "walking"
				if 0.0 < player.speed_current and player.speed_current <= player.speed_walking:
					# Set the sound effect speed
					audio_player.pitch_scale = .75

				# Check if the player speed is faster than "walking" but slower than or equal to "running"
				elif player.speed_walking < player.speed_current and player.speed_current <= player.speed_running:
					# Set the sound effect speed
					audio_player.pitch_scale = 1.0

				# Check if the player speed is faster than "running"
				elif player.speed_running < player.speed_current:
					# Set the sound effect speed
					audio_player.pitch_scale = 1.25

				# Check if the audio player is not playing or if the stream is not a "skateboarding" sound effect
				if not audio_player.playing or audio_player.stream not in [ollie_start_sound, ollie_land_sound, skateboarding_sound]:
					# Check if the player is on the ground
					if player.is_on_floor():
						# Set the audio player's stream to the "skateboarding" sound effect
						audio_player.stream = skateboarding_sound

						# Play the "skateboarding" sound effect
						audio_player.play()

			# The player must be not grounded
			else:
					# Check if the audio player is not streaming the "ollie start" sound effect
					if audio_player.stream != ollie_start_sound:
						# Stop the "skateboarding" sound effect
						audio_player.stop()

						# Clear the audio player's stream
						audio_player.stream = null

		# The player must not be moving
		else:
			# Check if the audio player is streaming a "skateboarding" sound effect
			if audio_player.stream in [ollie_start_sound, skateboarding_sound]:
				# Reset the sound effect speed
				audio_player.pitch_scale = 1.0

				# Stop the "skateboarding" sound effect
				audio_player.stop()

		# Check if the player is moving really slow (between -0.1 and 0.1)
		if abs(player.velocity.x) < 0.1 and abs(player.velocity.z) < 0.1:
			# Stop the player
			player.velocity.x = 0.0
			player.velocity.z = 0.0

			# Check if the audio player is streaming a "skateboarding" sound effect
			if audio_player.stream == skateboarding_sound:
				# Stop the "skateboarding" sound effect
				audio_player.stop()


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Reparent any foot items
		body.reparent_equipped_foot_items()
		# Load the scene
		var scene = load("res://scenes/skateboard.tscn")
		# Instantiate the scene
		var instance = scene.instantiate()
		# Set the player reference for the new skateboard instance
		instance.player = body
		# Disable the "pickup" collision
		instance.get_node("Area3D/CollisionShape3D").disabled = true
		# Add the instance to the player scene
		body.foot_mount.add_child(instance)
		# Remove _this_ instance
		queue_free()
		# Get the string name of the player's current state
		var current_state = body.base_state.get_state_name(body.current_state)
		# Start "skateboarding"
		body.base_state.transition(current_state, "Skateboarding")
