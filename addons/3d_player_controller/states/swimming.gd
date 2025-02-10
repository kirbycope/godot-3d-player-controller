extends BaseState

const animation_swimming = "Swimming_In_Place"
const animation_treading_water = "Treading_Water"
var node_name = "Swimming"

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
			if player.is_swimming_in:
				var water_top = player.is_swimming_in.get_parent().position.y + (player.is_swimming_in.get_child(0).shape.size.y / 2)
				var new_position = player.position.y + 0.01
				var player_top = new_position + player.collision_height/2
				if player_top <= water_top:
					player.position.y = new_position

	# Check if the player is not "swimming"
	if !player.is_swimming:

		# Start "standing"
		transition(node_name, "Standing")

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
			if player.animation_player.current_animation != animation_swimming:

				# Adjust player visuals for animation
				player.visuals_aux_scene.position.y = lerp(player.visuals_aux_scene.position.y, player.collision_height/2, 0.25)

				# Play the "swimming" animation
				player.animation_player.play(animation_swimming)

			# Check if the audio player is not playing or if the stream is not the "swimming" sound effect
			if not player.audio_player.playing or player.audio_player.stream != swimming_sound:
			
				# Set the audio player's stream to the "swimming" sound effect
				player.audio_player.stream = swimming_sound

				# Play the "swimming" sound effect
				player.audio_player.play()

		# The player must not be moving
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_treading_water:

				# [Re]set the player visuals postion
				player.visuals_aux_scene.position.y = player.collision_height / 4

				# Play the "treading water" animation
				player.animation_player.play(animation_treading_water)

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

	# Slow the player down
	player.velocity.y = player.velocity.y * 0.0

	# Get positional information
	if player.is_swimming_in:
		var parent_position = player.is_swimming_in.get_parent().position
		var child_size = player.is_swimming_in.get_child(0).shape.size
		var water_top = player.is_swimming_in.get_parent().position.y + (child_size.y / 2)
		var player_half_height = player.collision_height / 2
		
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

	# Remove which body the player is swimming in
	player.is_swimming_in = null

	# [Re]set the player visuals postion
	player.visuals_aux_scene.position.y = player.collision_height / 2

	# Stop the "swimming" sound effect
	if player.audio_player.stream == swimming_sound:

		# Stop the "swimming" sound effect
		player.audio_player.stop()

		# Clear the audio player's stream
		player.audio_player.stream = null
