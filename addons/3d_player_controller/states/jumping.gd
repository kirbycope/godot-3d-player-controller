extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player "is on floor"
				if player.is_on_floor():

					# Set the player's vertical velocity
					player.velocity.y = player.jump_velocity

					# Flag the player as not "double jumping"
					player.is_double_jumping = false

					# Flag the player as "jumping"
					player.is_jumping = true

				# The player must be in the air
				else:

					# Check if "double jump" is enabled and the player is not currently double-jumping
					if player.enable_double_jump and !player.is_double_jumping:

						# Set the player's vertical velocity
						player.velocity.y = player.jump_velocity

						# Set the "double jumping" flag
						player.is_double_jumping = true


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is on the ground (and has no vertical velocity) or is "flying"
	if (player.is_on_floor() and player.velocity.y ==  0.0) or player.is_flying:

		# Flag the player as not "double jumping"
		player.is_double_jumping = false

		# Flag the player as not "jumping"
		player.is_jumping = false

	# Check if the player is "jumping" (and the animation player is not locked)
	if player.is_jumping and !player.is_animation_locked:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_jumping_holding_rifle:

				# Play the "jumping, holding a rifle" animation
				player.animation_player.play(player.animation_jumping_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_jumping_holding_tool:

				# Play the "jumping, holding a tool" animation
				player.animation_player.play(player.animation_jumping_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_jumping:

				# Play the "jumping" animation
				player.animation_player.play(player.animation_jumping)
