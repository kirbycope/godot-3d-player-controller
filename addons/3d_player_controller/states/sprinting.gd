extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [sprint] button just _released_
		if Input.is_action_just_released("sprint"):

			# Flag the player as not "sprinting"
			player.is_sprinting = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# [sprint] button _pressed_ (and not already "sprinting")
	if Input.is_action_pressed("sprint") and !player.is_sprinting:

		# Check if the animation player is not locked
		if !player.is_animation_locked:

			# Flag the player as "sprinting"
			player.is_sprinting = true

			# Set the player's movement speed
			player.speed_current = player.speed_sprinting

	# Check if the player is "sprinting"
	if player.is_sprinting:

		# Check if the player is not "crouching" and is "on floor"
		if !player.is_crouching and player.is_on_floor():

			# Play the animation
			play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_sprinting_holding_rifle:

				# Play the "sprinting, holding a rifle" animation
				player.animation_player.play(player.animation_sprinting_holding_rifle)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_sprinting:

				# Play the "sprinting" animation
				player.animation_player.play(player.animation_sprinting)
