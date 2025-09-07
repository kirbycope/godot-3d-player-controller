extends BaseState

const ANIMATION_SITTING := "Sitting_Idle" + "/mixamo_com"
const NODE_NAME := "Sitting"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Stand up on [jump] or [move_*]
		if event.is_action_pressed("button_0") \
		or event.is_action_pressed("move_left") \
		or event.is_action_pressed("move_right") \
		or event.is_action_pressed("move_up") \
		or event.is_action_pressed("move_down"):
			transition(NODE_NAME, "Standing")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Check if the player is "sitting"
		if player.is_sitting:
			# Play the animation
			play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_SITTING:
			# Play the "sitting, idle" animation
			player.animation_player.play(ANIMATION_SITTING)


## Start "sitting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.SITTING
	# Flag the player as "sitting"
	player.is_sitting = true
	# Set the player's speed
	player.speed_current = 0.0
	# Set the player's velocity
	player.velocity = Vector3.ZERO


## Stop "sitting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "sitting"
	player.is_sitting = false
