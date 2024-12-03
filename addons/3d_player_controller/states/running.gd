extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Flag the player as not "running"
	player.is_running = false

	# Check if the player is moving on the ground (and not crouching)
	if player.velocity != Vector3(0.0, 0.0, 0.0) and player.is_on_floor() and !player.is_crouching:

		# Check if the player speed is more than "walking" and less than or equal to "running"
		if (player.speed_walking < player.speed_current) and (player.speed_current <= player.speed_running):

			# Flag the player as "running"
			player.is_running = true

	# Check if the player is "running"
	if player.is_running:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_running_holding_rifle:

				# Play the "running, holding rifle" animation
				player.animation_player.play(player.animation_running_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_running_holding_tool:

				# Play the "running, holding a tool" animation
				player.animation_player.play(player.animation_running_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_running:

				# Play the "running" animation
				player.animation_player.play(player.animation_running)
