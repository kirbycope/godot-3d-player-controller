extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Flag the player as not "walking"
	player.is_walking = false

	# Check if the player is moving on the ground (and not crouching)
	if player.velocity != Vector3(0.0, 0.0, 0.0) and player.is_on_floor() and !player.is_crouching:

		# Check if the player speed is slower than or equal to "walking"
		if player.speed_current <=player.speed_walking:

			# Flag the player as "walking"
			player.is_walking = true
	
	# Check if the player is "walking"
	if player.is_walking:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_walking_holding_rifle:

				# Play the "walking, holding rifle" animation
				player.animation_player.play(player.animation_walking_holding_rifle)

		# Check if the player is "holding a tool"
		if player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_walking_holding_tool:

				# Play the "walking, holding a tool" animation
				player.animation_player.play(player.animation_walking_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_walking:

				# Play the "walking" animation
				player.animation_player.play(player.animation_walking)


## Start "walking".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	States.current_state = States.State.WALKING

	# Flag the player as "walking"
	player.is_walking = true


## Stop "walking".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "walking"
	player.is_walking = false
