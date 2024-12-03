extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


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

					# Start "crouching"
					start_crouching()

		# [crouch] button just _released_
		if Input.is_action_just_released("crouch"):

			# Stop "crouching"
			stop_crouching()

		# [left-punch] button just _pressed_
		if Input.is_action_just_pressed("left_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "crouching" and is "on floor"
				if player.is_crouching and player.is_on_floor():

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

					# Check if the player is not "holding a rifle"
					if !player.is_holding_rifle:

						# Flag the animation player as locked
						player.is_animation_locked = true

						# Flag the player as "punching with their right arm"
						player.is_punching_right = true

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != player.punching_low_right:

							# Play the "punching low, right" animation
							player.animation_player.play(player.punching_low_right)

							# Check the punch hits something
							player.check_punch_collision()

		# [right-punch] button _pressed_
		if Input.is_action_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "crouching" and is "on floor"
				if player.is_crouching and player.is_on_floor():

					# Check if the player is "holding a rifle"
					if player.is_holding_rifle:

						# Flag the player as is "aiming"
						player.is_aiming = true

		# [right-punch] button just _released_
		if Input.is_action_just_released("right_punch"):

			# Check if the player is "holding a rifle"
			if player.is_holding_rifle:

				# Flag the player as not "aiming"
				player.is_aiming = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# [crouch] button _pressed_ (and not already "crouching")
	if Input.is_action_pressed("crouch") and !player.is_crouching:

		# Check if the animation player is not locked
		if !player.is_animation_locked:

			# Check if the player "is on floor"
			if player.is_on_floor():

				# Start "crouching"
				start_crouching()

	# Check if the player is "crouching"
	if player.is_crouching:

		# Check if the player is not moving
		if player.velocity == Vector3(0.0, 0.0, 0.0):

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
				if player.animation_player.current_animation != player.animation_crouching_firing_rifle:

					# Play the "crouching, firing rifle" animation
					player.animation_player.play(player.animation_crouching_firing_rifle)

			# Check if the player is "aiming"
			elif player.is_aiming:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != player.animation_crouching_aiming_rifle:

					# Play the "crouching, aiming a rifle" animation
					player.animation_player.play(player.animation_crouching_aiming_rifle)

			# The player must be "idle"
			else:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != player.animation_crouching_holding_rifle:

					# Play the "crouching idle, holding rifle" animation
					player.animation_player.play(player.animation_crouching_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_crouching_holding_tool:

				# Play the "crouching, holding tool" animation
				player.animation_player.play(player.animation_crouching_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_crouching:

				# Play the "crouching" animation
				player.animation_player.play(player.animation_crouching)


## Called when the player starts "crouching".
func start_crouching() -> void:

	# Flag the player as "crouching"
	player.is_crouching = true

	# Set the player's movement speed
	player.speed_current = player.speed_crawling

	# Set CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2

	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position / 2


## Called when the player stops "crouching".
func stop_crouching() -> void:

	# Flag player as not "crouching"
	player.is_crouching = false

	# [Re]Set the player's movement speed
	player.speed_current = player.speed_walking

	# Reset CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height

	# Reset CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position
