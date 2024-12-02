extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Flag the player as not "crawling"
	player.is_crawling = false

	# Check if the player is moving on the ground and is "crouching"
	if player.velocity != Vector3(0.0, 0.0, 0.0) and player.is_on_floor() and player.is_crouching:

		# Flag the player as "crawling"
		player.is_crawling = true

	# Check if the player is "crawling" (and the animation player is not locked)
	if player.is_crawling and !player.is_animation_locked:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not already playing the appropriate animation
	if player.animation_player.current_animation != player.animation_crawling:

		# Play the "crawling" animation
		player.animation_player.play(player.animation_crawling)
