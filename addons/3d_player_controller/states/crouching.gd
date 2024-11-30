extends Node

@onready var player = Globals.get_player()


## Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [crouch] button _pressed_
		if Input.is_action_just_pressed("crouch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player "is on floor"
				if player.is_on_floor():

					# Flag the player as "crouching"
					player.is_crouching = true

					# Set CollisionShape3D height
					player.get_node("CollisionShape3D").shape.height = player.collision_height / 2

					# Set CollisionShape3D position
					player.get_node("CollisionShape3D").position = player.collision_position / 2

		# [crouch] button just _released_
		if Input.is_action_just_released("crouch"):

			# Flag player as not "crouching"
			player.is_crouching = false

			# Reset CollisionShape3D height
			player.get_node("CollisionShape3D").shape.height = player.collision_height

			# Reset CollisionShape3D position
			player.get_node("CollisionShape3D").position = player.collision_position

		# [left-punch] button just _pressed_
		if Input.is_action_just_pressed("left_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "crouching" and is "on floor"
				if player.is_crouching and player.is_on_floor():

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						pass # ToDo: Firing while kneeling

					# The player must be unarmed
					else:

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.punching_low_left:

							# Play the "punching low, left" animation
							player.animation_player.play(player.punching_low_left)

							# Check the punch hits something
							player.check_punch_collision()

		# [right-punch] button just _pressed_
		if Input.is_action_just_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "crouching" and is "on floor"
				if player.is_crouching and player.is_on_floor():

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						pass # ToDo: Firing while kneeling

					# The player must be unarmed
					else:

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.punching_low_right:

							# Play the "punching low, right" animation
							player.animation_player.play(player.punching_low_right)

							# Check the punch hits something
							player.check_punch_collision()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the crouching button is held (after the player becomes airbourne)
	if Input.is_action_pressed("crouch") and player.is_on_floor():

		# Flag the player as "crouching"
		player.is_crouching = true

	# Check if the player is "crouching"
	if player.is_crouching:

		# Set the player's movement speed
		player.speed_current = player.speed_crawling

		# If no relevant animation is playing, play an "idle" animation
		if player.animation_player.current_animation not in player.animations_crouching:

			# Check if the player is "holding a rifle"
			if player.is_holding_rifle:

				# Play the "crouching, holding a rifle" animation
				player.animation_player.play(player.animation_crouching_aiming_rifle)

			# The player must be unarmed
			else:

				# Play the "crouching" animation
				player.animation_player.play(player.animation_crouching)

	# The player must not be "crouching"
	else:

			# Check if the current animation is still a "crouching" one
			if player.animation_player.current_animation in player.animations_crouching:

				# Stop the animation
				player.animation_player.stop()
