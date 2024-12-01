extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Flag the player as not "walking"
	player.is_walking = false

	# Check if the player is moving on the ground (and not crouching)
	if player.velocity != Vector3(0.0, 0.0, 0.0) and player.is_on_floor() and !player.is_crouching:

		# Check if the player speed is slower than "running"
		if player.speed_current < player.speed_running:

			# Flag the player as "walking"
			player.is_walking = true

	# <Animations> Check if the player is "walking"
	if player.is_walking:

		# Check if a relevant animation is not playing
		if player.animation_player.current_animation != "" and player.animation_player.current_animation not in player.animations_walking:

			# Check if the player is "holding a rifle"
			if player.is_holding_rifle:

				# Play the "walking, holding a rifle" animation
				player.animation_player.play(player.animation_walking_holding_rifle)

			# The player must be unarmed
			else:

				# Play the "walking" animation
				player.animation_player.play(player.animation_walking)
