extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [left-kick] button _pressed_
		if Input.is_action_pressed("left_kick"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is not "holding a rifle"
					if !player.is_holding_rifle:

						# Flag the animation player as locked
						player.is_animation_locked = true

						# Flag the player as "kicking with their left leg"
						player.is_kicking_left = true

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.kicking_low_left:

							# Play the "kicking low, left" animation
							player.animation_player.play(player.kicking_low_left)

							# Check the kick hits something
							player.check_kick_collision()

		# [right-kick] button _pressed_
		if Input.is_action_pressed("right_kick"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is not "holding a rifle"
					if !player.is_holding_rifle:

						# Flag the animation player as locked
						player.is_animation_locked = true

						# Flag the player as "kicking with their right leg"
						player.is_kicking_right = true

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.kicking_low_right:

							# Play the "kicking low, right" animation
							player.animation_player.play(player.kicking_low_right)

							# Check the kick hits something
							player.check_kick_collision()

		# [left-punch] button just _pressed_
		if Input.is_action_just_pressed("left_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						# Flag the player as is "firing"
						player.is_firing = true

						# Delay execution
						await get_tree().create_timer(0.3).timeout

						# Flag the player as is not "firing"
						player.is_firing = false

					# The player must be unarmed
					else:

						# Flag the animation player as locked
						player.is_animation_locked = true

						# Flag the player as "punching with their left arm"
						player.is_punching_left = true

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.punching_high_left:

							# Play the "punching high, left" animation
							player.animation_player.play(player.punching_high_left)

							# Check the punch hits something
							player.check_punch_collision()

		# [right-punch] button just _pressed_
		if Input.is_action_just_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is not "holding a rifle"
					if !player.is_holding_rifle:

						# Flag the animation player as locked
						player.is_animation_locked = true

						# Flag the player as "punching with their right arm"
						player.is_punching_right = true

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.punching_high_right:

							# Play the "punching high, right" animation
							player.animation_player.play(player.punching_high_right)

							# Check the punch hits something
							player.check_punch_collision()

		# [right-punch] button _pressed_
		if Input.is_action_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						# Flag the player as "aiming"
						player.is_aiming = true

		# [right-punch] button just _released_
		if Input.is_action_just_released("right_punch"):

			# Check if the player is "holding a rifle"
			if player.is_holding_rifle:

				# Flag the player as not "aiming"
				player.is_aiming = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Flag the player as not "standing"
	player.is_standing = false

	# Check if the player is not moving (and on the ground)
	if player.velocity == Vector3(0.0, 0.0, 0.0) and player.is_on_floor():

		# Check if the player is not "crouching" or "jumping"
		if !player.is_crouching and !player.is_jumping:

			# Flag the player as "standing"
			player.is_standing = true

			# Set the player's movement speed
			player.speed_current = player.speed_walking

	# Check if the player is "walking"
	if player.is_standing:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the player is "firing"			
			if player.is_firing:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != player.animation_standing_firing_rifle:

					# Play the "standing, firing rifle" animation
					player.animation_player.play(player.animation_standing_firing_rifle)

			# Check if the player is "aiming"
			elif player.is_aiming:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != player.animation_standing_aiming_rifle:

					# Play the "standing, aiming rifle" animation
					player.animation_player.play(player.animation_standing_aiming_rifle)

			# The player must be "idle"
			else:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != player.animation_standing_holding_rifle:

					# Play the "standing idle, holding rifle" animation
					player.animation_player.play(player.animation_standing_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_standing_holding_tool:

				# Play the "standing, holding tool" animation
				player.animation_player.play(player.animation_standing_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_standing:

				# Play the "standing idle" animation
				player.animation_player.play(player.animation_standing)
