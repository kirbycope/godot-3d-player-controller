extends BaseState

const animation_running = "Running_In_Place"
const animation_running_aiming_rifle = "Rifle_Aiming_Run_In_Place"
const animation_running_holding_rifle = "Rifle_Low_Run_In_Place"
const animation_running_holding_tool = "Running_In_Place_With_Sword_Right"
var node_name = "Running"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [crouch] button just _pressed_ and crouching is enabled
		if event.is_action_pressed("crouch") and player.enable_crouching:

			# Start "crouching"
			transition(node_name, "Crouching")

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			transition(node_name, "Jumping")

		# [sprint] button _pressed_
		if event.is_action_pressed("sprint"):

			# Start "sprinting"
			transition(node_name, "Sprinting")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:

		# Start "standing"		
		transition(node_name, "Standing")

	# The player must be moving
	else:

		# Check if the player speed is slower than or equal to "walking"
		if player.speed_current <= player.speed_walking:

			# Start "walking"
			transition(node_name, "Walking")

		# Check if the player speed is faster than "running" but slower than or equal to "sprinting"
		elif player.speed_running < player.speed_current and player.speed_current <= player.speed_sprinting:

			# Start "sprinting"
			transition(node_name, "Sprinting")

	# Check if the player is "running"
	if player.is_running:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_running_holding_rifle:

				# Play the "running, holding rifle" animation
				player.animation_player.play(animation_running_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_running_holding_tool:

				# Play the "running, holding a tool" animation
				player.animation_player.play(animation_running_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_running:

				# Play the "running" animation
				player.animation_player.play(animation_running)


## Start "running".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.RUNNING

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
