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


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is "jumping"
	if player.is_jumping:

		# Check if a relevant animation is playing
		if player.animation_player.current_animation not in player.animations_jumping:

			# Check if the player is "holding a rifle"
			if player.is_holding_rifle:

				# Play the "jumping, holding a rifle" animation
				player.animation_player.play(player.animation_jumping_holding_rifle)

			# The player must be unarmed
			else:

				# Play the "jumping animation
				player.animation_player.play(player.animation_jumping)
