extends BaseState

const ANIMATION_SWIMMING := "Swimming_In_Place" + "/mixamo_com"
const ANIMATION_TREADING_WATER := "Treading_Water" + "/mixamo_com"
const NODE_NAME := "Swimming"

@onready var swimming_sound = preload("res://addons/3d_player_controller/sounds/398037__swordofkings128__water-swimming-1_2.mp3") as AudioStream


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the game is not paused
	if !player.game_paused:

		# [crouch] button just _pressed_
		if Input.is_action_pressed("crouch"):

			# Decrement the player's vertical position
			player.position.y -= 0.01

		# [jump] button just _pressed_
		if Input.is_action_pressed("jump"):

			# Check if the player is swimming in a body of water
			if player.is_swimming_in:

				# Get the water level (top of water body)
				var water_top = player.is_swimming_in.get_parent().position.y + (player.is_swimming_in.get_child(0).shape.size.y / 2)

				# Get the player's new position (if it were incremented)
				var new_position = player.position.y + 0.01

				# Get the player's top position (position + height)
				var player_top = new_position + (player.collision_height * .75)

				# Check if the water is above the player
				if player_top <= water_top:

					# Increment the player's vertical position
					player.position.y = new_position

	# Check if the player is not "swimming"
	if !player.is_swimming:

		# Start "standing"
		transition(NODE_NAME, "Standing")

	# Check if the player is "swimming"
	if player.is_swimming:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is moving
		if player.velocity != Vector3.ZERO:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_SWIMMING:

				# Move the collison shape to match the player
				player.collision_shape.rotation_degrees.x = 90

				# Adjust player visuals for animation
				player.visuals_aux_scene.position.y = lerp(player.visuals_aux_scene.position.y, player.collision_height * .5, 0.1)

				# Play the "swimming" animation
				player.animation_player.play(ANIMATION_SWIMMING)

			# Check if the audio player is not playing or if the stream is not the "swimming" sound effect
			if not player.audio_player.playing or player.audio_player.stream != swimming_sound:
			
				# Set the audio player's stream to the "swimming" sound effect
				player.audio_player.stream = swimming_sound

				# Play the "swimming" sound effect
				player.audio_player.play()

		# The player must not be moving
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_TREADING_WATER:

				# Move the collison shape to match the player
				player.collision_shape.rotation_degrees.x = 0

				# [Re]set the player visuals postion
				player.visuals_aux_scene.position.y = 0.0

				# Play the "treading water" animation
				player.animation_player.play(ANIMATION_TREADING_WATER)

			# Check if the audio player is streaming the "swimming" sound effect
			if player.audio_player.stream == swimming_sound:

				# Stop the "swimming" sound effect
				player.audio_player.stop()

				# Clear the audio player's stream
				player.audio_player.stream = null


## Start "swimming".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SWIMMING

	# Flag the player as "swimming"
	player.is_swimming = true

	# Set the player's speed
	player.speed_current = player.speed_swimming

	# Set player properties
	player.gravity = 0.0
	player.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	player.position.y += 0.1
	player.velocity.y = 0.0

	# Get positional information
	if player.is_swimming_in:
		var parent_position = player.is_swimming_in.get_parent().position
		var child_size = player.is_swimming_in.get_child(0).shape.size
		var water_top = player.is_swimming_in.get_parent().position.y + (child_size.y / 2)
		var player_half_height = player.collision_height * .75
		
		# Check if the player is below water level
		if (player.position.y + player_half_height) < (parent_position.y + water_top):

			# Set the player's vertical position to be at water level
			player.position.y = water_top - player_half_height


## Stop "swimming".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "swimming"
	player.is_swimming = false

	# [Re]Set player properties
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	player.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	player.velocity.y -= player.gravity
	player.visuals.rotation.x = 0
	player.visuals_aux_scene.position.y = 0.0

	# Remove which body the player is swimming in
	player.is_swimming_in = null

	# Reset the collison shape to match the player
	player.collision_shape.rotation_degrees.x = 0

	# Stop the "swimming" sound effect
	if player.audio_player.stream == swimming_sound:

		# Stop the "swimming" sound effect
		player.audio_player.stop()

		# Clear the audio player's stream
		player.audio_player.stream = null
