extends BaseState

const ANIMATION_RUNNING := "Running_In_Place" + "/mixamo_com"
const ANIMATION_RUNNING_AIMING_RIFLE := "Rifle_Aiming_Run_In_Place" + "/mixamo_com"
const ANIMATION_RUNNING_HOLDING_RIFLE := "Rifle_Low_Run_In_Place" + "/mixamo_com"
const ANIMATION_RUNNING_HOLDING_TOOL := "Running_In_Place_With_Sword_Right" + "/mixamo_com"
const NODE_NAME := "Running"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓨ/[Ctrl] just _pressed_ and crouching is enabled -> Start "crouching"
		if event.is_action_pressed("button_3") and player.enable_crouching:
			# Start "crouching"
			transition(NODE_NAME, "Crouching")

		# Ⓐ/[Space] button just _pressed_ and jumping is enabled -> Start "jumping"
		if event.is_action_pressed("button_0") and player.enable_jumping and !player.is_animation_locked:
			# Start "jumping"
			transition(NODE_NAME, "Jumping")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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

		# Check if the player speed is slower than or equal to "walking"
		if player.speed_current <= player.speed_walking:
			# Start "walking"
			transition(NODE_NAME, "Walking")

		# Check if the player speed is faster than "running" but slower than or equal to "sprinting"
		elif player.speed_running < player.speed_current and player.speed_current <= player.speed_sprinting:
			# Check if sprinting is enabled
			if player.enable_sprinting:
				# Start "sprinting"
				transition(NODE_NAME, "Sprinting")

	# [sprint] button _pressed_
	if Input.is_action_pressed("button_1") and !player.is_animation_locked:
		# Check if sprinting is enabled
		if player.enable_sprinting:
			# Start "sprinting"
			transition(NODE_NAME, "Sprinting")

	# Check if the player is "running"
	if player.is_running:
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
			if player.animation_player.current_animation != ANIMATION_RUNNING_HOLDING_RIFLE:
				# Play the "running, holding rifle" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_RUNNING_HOLDING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_RUNNING_HOLDING_RIFLE)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_RUNNING_HOLDING_TOOL:
				# Play the "running, holding a tool" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_RUNNING_HOLDING_TOOL)
				else:
					player.animation_player.play(ANIMATION_RUNNING_HOLDING_TOOL)

		# The player must be unarmed
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_RUNNING:
				# Play the "running" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_RUNNING)
				else:
					player.animation_player.play(ANIMATION_RUNNING)


## Start "running".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = STATES.State.RUNNING

	# Flag the player as "running"
	player.is_running = true

	# Set the player's speed
	player.speed_current = player.speed_running


## Stop "running".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "running"
	player.is_running = false
