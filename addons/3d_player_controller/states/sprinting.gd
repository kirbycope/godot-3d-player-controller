extends BaseState

const ANIMATION_SPRINTING := "Sprinting_In_Place" + "/mixamo_com"
const ANIMATION_SPRINTING_HOLDING_RIFLE := "Rifle_Sprinting_In_Place" + "/mixamo_com"
const ANIMATION_SPRINTING_HOLDING_TOOL := "Tool_Sprinting_In_Place" + "/mixamo_com"
const NODE_NAME := "Sprinting"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓐ/[Space] _pressed_ and jumping is enabled -> Start "jumping"
		if event.is_action_pressed("button_0") and player.enable_jumping and !player.is_animation_locked:
			# Start "jumping"
			transition(NODE_NAME, "Jumping")
		# Ⓑ/[Shift] _released_ -> Stop "sprinting"
		if event.is_action_released("button_1"):
			# Start "standing" (which will check the player's speed and transition them to another state as needed)
			transition(NODE_NAME, "Standing")
		# Ⓨ/[Ctrl] _pressed_ -> Start "sliding"
		if event.is_action_pressed("button_3") and player.enable_sliding and !player.is_animation_locked:
			# Start "sliding"
			transition(NODE_NAME, "Sliding")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:
		# Start "standing"
		transition(NODE_NAME, "Standing")
	# The player must be moving
	else:
		# Check if the player is not on a floor
		if !player.is_on_floor() and !player.raycast_below.is_colliding():
			# Start "falling"
			transition(NODE_NAME, "Falling")
	# Check if the player is "sprinting"
	if player.is_sprinting:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if in first person and moving backwards
		var play_backwards = player.perspective == 1 and Input.is_action_pressed("move_down")
		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_SPRINTING_HOLDING_RIFLE:
				# Play the "sprinting, holding a rifle" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_SPRINTING_HOLDING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_SPRINTING_HOLDING_RIFLE)
		# The player must be unarmed
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_SPRINTING:
				# Play the "sprinting" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_SPRINTING)
				else:
					player.animation_player.play(ANIMATION_SPRINTING)


## Start "sprinting".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.SPRINTING
	# Flag the player as "sprinting"
	player.is_sprinting = true
	# Set the player's speed
	player.speed_current = player.speed_sprinting


## Stop "sprinting".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "sprinting"
	player.is_sprinting = false
