extends BaseState

const ANIMATION_FLYING := "Flying_In_Place" + "/mixamo_com"
const ANIMATION_FLYING_FAST := "Flying_Fast_In_Place" + "/mixamo_com"
const NODE_NAME := "Flying"
var timer_jump = 0.0


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the game is not paused
	if !player.game_paused:

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if "jump timer" hasn't started
				if timer_jump == 0.0:

					# Set the "jump timer" to the current game time
					timer_jump = Time.get_ticks_msec()

				# Check if the "jump timer" is already running
				elif timer_jump > 0.0:

					# Get the current game time
					var time_now = Time.get_ticks_msec()

					# Check if _this_ button press is within 200 milliseconds
					if time_now - timer_jump < 200:

						# Start "falling"
						transition(NODE_NAME, "Falling")
						
						# Stop processing inputs (this frame)
						return

					# Either way, reset the timer
					timer_jump = Time.get_ticks_msec()

		# [crouch] button just _pressed_
		if Input.is_action_just_pressed("crouch"):

			# Pitch the player slightly downward
			player.visuals.rotation.x = deg_to_rad(-6)
		
		# [crouch] button currently _pressed_
		if Input.is_action_pressed("crouch"):

			# Decrease the player's vertical position
			player.position.y -= 5 * delta

			# End ANIMATION_FLYING if collision detected below the player
			if player.raycast_below.is_colliding():

				# Start "standing"
				transition(NODE_NAME, "Standing")
		
		# [crouch] button just _released_
		if Input.is_action_just_released("crouch"):

			# Reset the player's pitch
			player.visuals.rotation.x = 0

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump"):
	
			# Pitch the player slightly downward
			player.visuals.rotation.x = deg_to_rad(6)

		# [jump] button currently _pressed_
		if Input.is_action_pressed("jump"):

			# Increase the player's vertical position
			player.position.y += 5 * delta

		# [jump] button just _released_
		if Input.is_action_just_released("jump"):

			# Reset the player's pitch
			player.visuals.rotation.x = 0

		# [sprint] button _pressed_
		if Input.is_action_pressed("sprint"):

			# Check if the player is not "sprinting"
			if !player.is_sprinting:

				# Set the player's speed
				player.speed_current = player.speed_flying_fast

				# Flag the player as "sprinting"
				player.is_sprinting = true

		# [sprint] button just _released_
		if Input.is_action_just_released("sprint"):

			# Set the player's speed
			player.speed_current = player.speed_flying

			# Flag the player as not "sprinting"
			player.is_sprinting = false

	# Check if the player is "flying"
	if player.is_flying:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "sprinting"
		if player.is_sprinting:

			# Check if the current animation is not a ANIMATION_FLYING one
			if player.animation_player.current_animation != ANIMATION_FLYING_FAST:

				# Play the animation "ANIMATION_FLYING Fast" animation
				player.animation_player.play(ANIMATION_FLYING_FAST)

		# The player must not be "sprinting"
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_FLYING:

				# Play the "flying" animation
				player.animation_player.play(ANIMATION_FLYING)


## Start "flying".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.FLYING

	# Flag the player as "flying"
	player.is_flying = true

	# Set the player's speed
	player.speed_current = player.speed_flying

	# Set player properties
	player.gravity = 0.0
	player.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	player.position.y += 0.1
	player.velocity.y = 0.0


## Stop "flying".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "flying"
	player.is_flying = false

	# [Re]Set player properties
	player.visuals.rotation.x = 0
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	player.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	player.velocity.y -= player.gravity
