extends Node

@onready var player = Globals.get_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if no animation is playing
	if !player.animation_player.is_playing():

		# Flag the animation player no longer locked
		player.is_animation_locked = false

		# Reset player state(s)
		player.is_kicking_left = false
		player.is_kicking_right = false
		player.is_punching_left = false
		player.is_punching_right = false

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_standing_idle_holding_rifle:

				# Play the "kicking low, left" animation
				player.animation_player.play(player.animation_standing_idle_holding_rifle)

		# The player must be unarmed
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_standing_idle:

				# Play the "kicking low, left" animation
				player.animation_player.play(player.animation_standing_idle)
