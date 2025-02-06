extends BaseState

const animation_skateboarding_fast = "Skateboarding_Fast_In_Place"
const animation_skateboarding_normal = "Skateboarding_In_Place"
const animation_skateboarding_slow = "Skateboarding_Slow_In_Place"
var node_name = "Skateboarding"

@onready var ollie_land_sound = preload("res://addons/3d_player_controller/sounds/LandConc.wav") as AudioStream
@onready var ollie_start_sound = preload("res://addons/3d_player_controller/sounds/OllieConc.wav") as AudioStream
@onready var skateboarding_sound = preload("res://addons/3d_player_controller/sounds/RollConcSmooth.wav") as AudioStream


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [crouch] button _pressed_
		if event.is_action_pressed("crouch"):

			# Check if the player is on the ground
			if player.is_on_floor():

				# Flag the player as "crouching"
				player.is_crouching = true

				# Set the player's speed
				player.speed_current = player.speed_crawling

		# [crouch] button _release_
		if event.is_action_released("crouch"):

			# Flag the player as not "crouching"
			player.is_crouching = false

			# Set the player's speed
			player.speed_current = player.speed_running

		# [jump] button just _pressed_
		if event.is_action_pressed("jump"):

			# Check if the player is on the ground
			if player.is_on_floor():

				# Flag the player as "jumping"
				player.is_jumping = true

				# Set the player's vertical velocity
				player.velocity.y = player.jump_velocity

				# Set the audio player's stream to the "ollie start" sound effect
				player.audio_player.stream = ollie_start_sound

				# Play the sound effect
				player.audio_player.play()

		# [sprint] button _pressed_
		if event.is_action_pressed("sprint"):

			# Set the player's speed
			player.speed_current = player.speed_sprinting
		
		# [sprint] button _release_
		if event.is_action_released("sprint"):

			# Set the player's speed
			player.speed_current = player.speed_running


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is not "skateboarding"
	if !player.is_skateboarding:

		# Start "standing"
		transition(node_name, "Standing")

	# Check if the player is "skateboarding"
	if player.is_skateboarding:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Set the animation player to the default speed
		player.animation_player.speed_scale = 1.0

		# Check if the player is on the ground and flagged as "jumping"
		if player.velocity.y == 0 and player.is_jumping:

			# Flag the player as not "jumping"
			player.is_jumping = false

			# Set the audio player's stream to the "ollie land" sound effect
			player.audio_player.stream = ollie_land_sound

			# Play the sound effect
			player.audio_player.play()

		# Check if the player is moving
		if player.velocity != Vector3.ZERO:

			# Check if the player is grounded
			if player.velocity.y == 0:

				# Check if the player is slower than or equal to "walking"
				if 0.0 < player.speed_current and player.speed_current <= player.speed_walking:

					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != animation_skateboarding_slow:

						# Play the "slow skateboarding" animation
						player.animation_player.play(animation_skateboarding_slow)

					# Set the sound effect speed
					player.audio_player.pitch_scale = .75

				# Check if the player speed is faster than "walking" but slower than or equal to "running"
				elif player.speed_walking < player.speed_current and player.speed_current <= player.speed_running:

					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != animation_skateboarding_normal:

						# Play the "normal skateboarding" animation
						player.animation_player.play(animation_skateboarding_normal)

					# Set the sound effect speed
					player.audio_player.pitch_scale = 1.0

				# Check if the player speed is faster than "running"
				elif player.speed_running < player.speed_current:

					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != animation_skateboarding_fast:

						# Play the "slow skateboarding" animation
						player.animation_player.play(animation_skateboarding_fast)

					# Set the sound effect speed
					player.audio_player.pitch_scale = 1.25

				# Check if the audio player is not playing or if the stream is not a "skateboarding" sound effect
				if not player.audio_player.playing or player.audio_player.stream not in [ollie_start_sound, ollie_land_sound, skateboarding_sound]:

					# Check if the player is on the ground
					if player.is_on_floor():

						# Set the audio player's stream to the "skateboarding" sound effect
						player.audio_player.stream = skateboarding_sound

						# Play the "skateboarding" sound effect
						player.audio_player.play()

			# The player must be not grounded
			else:

				# Check if the audio player is not streaming the "ollie start" sound effect
				if player.audio_player.stream != ollie_start_sound:

					# Stop the "skateboarding" sound effect
					player.audio_player.stop()

					# Clear the audio player's stream
					player.audio_player.stream = null

					# Flag the player as "jumping"
					player.is_jumping = true

		# The player must not be moving
		else:

			# Check if the audio player is streaming a "skateboarding" sound effect
			if player.audio_player.stream in [ollie_start_sound, skateboarding_sound]:

				# Play the "slow skateboarding" animation
				player.animation_player.play(animation_skateboarding_slow)

				# Slow down the animation player
				player.animation_player.speed_scale = 0.5

				# Reset the sound effect speed
				player.audio_player.pitch_scale = 1.0

		# Check if the player is moving really slow (between -0.1 and 0.1)
		if abs(player.velocity.x) < 0.1 and abs(player.velocity.z) < 0.1:

			# Stop the player
			player.velocity.x = 0.0
			player.velocity.z = 0.0

			# Check if the audio player is streaming a "skateboarding" sound effect
			if player.audio_player.stream == skateboarding_sound:

				# Stop the "skateboarding" sound effect
				player.audio_player.stop()

## Start "skateboarding".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SKATEBOARDING

	# Flag the player as "skateboarding"
	player.is_skateboarding = true


## Stop "skateboarding".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "skateboarding"
	player.is_skateboarding = false

	# Stop the "skateboarding" sound effect
	if player.audio_player.stream == skateboarding_sound:

		# Stop the "skateboarding" sound effect
		player.audio_player.stop()

		# Clear the audio player's stream
		player.audio_player.stream = null
