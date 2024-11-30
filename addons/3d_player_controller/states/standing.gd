extends Node

@onready var player = Globals.get_player()


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

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						pass # ToDo: ?

					# The player must be unarmed
					else:

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

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						pass # ToDo: ?

					# The player must be unarmed
					else:

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

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.animation_standing_firing_rifle:

							# Play the "standing, firing rifle" animation
							player.animation_player.play(player.animation_standing_firing_rifle)

					# The player must be unarmed
					else:

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

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.punching_high_right:

							# Play the "punching high, right" animation
							player.animation_player.play(player.punching_high_right)

							# Check the punch hits something
							player.check_punch_collision()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is "standing"
	if (!player.is_climbing
		and !player.is_crouching
		and !player.is_flying
		and !player.is_hanging
		and !player.is_jumping
		#and !player.is_running
		and !player.is_sprinting
	):

		# Set the player's movement speed
		player.speed_current = player.speed_walking

	# [right-punch] button _pressed_
	if Input.is_action_pressed("right_punch"):

		# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.animation_standing_aiming_rifle:

							# Play the "standing idle, aiming rifle" animation
							player.animation_player.play(player.animation_standing_aiming_rifle)
