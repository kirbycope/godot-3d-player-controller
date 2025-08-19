extends BaseState

const ANIMATION_PARAGLIDING := "Hanging_Idle" + "/mixamo_com"
const NODE_NAME := "Paragliding"


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is "paragliding"
	if player.is_paragliding:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if playing the "paragliding" animation
		if player.animation_player.current_animation != ANIMATION_PARAGLIDING:
			# Play the "paragliding" animation
			player.animation_player.play(ANIMATION_PARAGLIDING)


## Start "paragliding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = STATES.State.PARAGLIDING

	# Flag the player as "paragliding"
	player.is_paragliding = true


## Stop "paragliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "paragliding"
	player.is_paragliding = false

	# Remove the paraglider with the player
	player.is_paragliding_on = null
