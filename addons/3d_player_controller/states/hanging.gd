extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is "hanging"
	if player.is_hanging:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != player.animation_hanging:

			# Play the "hanging" animation
			player.animation_player.play(player.animation_hanging)
