extends BaseState

const ANIMATION_WALKING := "Walking_In_Place" + "/mixamo_com"
const ANIMATION_WALKING_AIMING_RIFLE := "Rifle_Walking_Aiming" + "/mixamo_com"
const ANIMATION_WALKING_FIGHTING_RIFLE := "Rifle_Walking_Firing" + "/mixamo_com"
const ANIMATION_WALKING_HOLDING_RIFLE := "Rifle_Low_Run_In_Place" + "/mixamo_com"
const ANIMATION_WALKING_HOLDING_TOOL := "Tool_Walking_In_Place" + "/mixamo_com"
const NODE_NAME := "Walking"


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:

		# Start "standing"		
		transition(NODE_NAME, "Standing")

	# The player must be moving
	else:

		# Check if the player speed is faster than "walking" but slower than or equal to "running"
		if player.speed_walking < player.speed_current and player.speed_current <= player.speed_running:

			# Start "running"
			transition(NODE_NAME, "Running")

		# Check if the player speed is faster than "running" but slower than or equal to "sprinting"
		elif player.speed_running < player.speed_current and player.speed_current <= player.speed_sprinting:

			# Start "sprinting"
			transition(NODE_NAME, "Sprinting")

		# [sprint] button _pressed_
		if Input.is_action_pressed("sprint"):

			# Start "sprinting"
			transition(NODE_NAME, "Sprinting")

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
			if player.animation_player.current_animation != ANIMATION_WALKING_HOLDING_RIFLE:

				# Play the "walking, holding rifle" animation
				player.animation_player.play(ANIMATION_WALKING_HOLDING_RIFLE)

		# Check if the player is "holding a tool"
		if player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_WALKING_HOLDING_TOOL:

				# Play the "walking, holding a tool" animation
				player.animation_player.play(ANIMATION_WALKING_HOLDING_TOOL)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_WALKING:

				# Play the "walking" animation
				player.animation_player.play(ANIMATION_WALKING)


## Start "walking".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.WALKING

	# Flag the player as "walking"
	player.is_walking = true

	# Set the player's speed
	player.speed_current = player.speed_walking


## Stop "walking".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "walking"
	player.is_walking = false
