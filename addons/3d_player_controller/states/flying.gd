extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player "is not on floor"
				if !player.is_on_floor():

					# Check if "animation_flying" is enabled and the player is not already animation_flying
					if player.enable_flying and !player.is_flying:

						# Start animation_flying
						start_flying()

					# Check if "animation_flying" but the "jump timer" hasn't started
					if player.is_flying and player.timer_jump == 0.0:

						# Set the "jump timer" to the current game time
						player.timer_jump = Time.get_ticks_msec()

					# Check if "animation_flying" and the "jump timer" is already running
					elif player.is_flying and player.timer_jump > 0.0:

						# Get the current game time
						var time_now = Time.get_ticks_msec()

						# Check if _this_ button press is within 200 milliseconds
						if time_now - player.timer_jump < 200:

							# Stop animation_flying
							stop_flying()

						# Either way, reset the timer
						player.timer_jump = Time.get_ticks_msec()
	
		# Check if the player is "flying"
		if player.is_flying:

			# [crouch] button just _pressed_
			if Input.is_action_just_pressed("crouch"):

				# Pitch the player slightly downward
				player.visuals.rotation.x = deg_to_rad(-6)
			
			# [crouch] button currently _pressed_
			if Input.is_action_pressed("crouch"):

				# Decrease the player's vertical position
				player.position.y -= 0.1

				# End animation_flying if collision detected below the player
				if player.raycast_below.is_colliding():

					# Stop animation_flying
					stop_flying()
			
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
				player.position.y += 0.1

			# [jump] button just _released_
			if Input.is_action_just_released("jump"):

				# Reset the player's pitch
				player.visuals.rotation.x = 0

		# Check if the player is "flying" (and the animation player is not locked)
		if player.is_flying and !player.is_animation_locked:

			# Play the animation
			play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the player is "sprinting"
	if player.is_sprinting:

		# Check if the current animation is not a animation_flying one
		if player.animation_player.current_animation != player.animation_flying_fast:

			# Play the animation_standing "animation_flying Fast" animation
			player.animation_player.play(player.animation_flying_fast)

	# The player must not be "sprinting"
	else:

		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != player.animation_flying:

			# Play the "flying" animation
			player.animation_player.play(player.animation_flying)


## Called when the player starts "flying".
func start_flying() -> void:
	player.gravity = 0.0
	player.motion_mode = 1 # MOTION_MODE_FLOATING
	player.position.y += 0.1
	player.velocity.y = 0.0
	player.is_flying = true


## Called when the player stops "flying".
func stop_flying() -> void:
	player.gravity = 9.8
	player.motion_mode = 0 # MOTION_MODE_GROUNDED
	player.velocity.y -= player.gravity
	player.visuals.rotation.x = 0
	player.is_flying = false
