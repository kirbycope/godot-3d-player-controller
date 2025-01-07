extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [crouch] button just _pressed_ and crouching is enabled
		if Input.is_action_just_pressed("crouch") and player.enable_crouching:

			# Start "crouching"
			to_crouching()

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			to_jumping()

		# [sprint] button _pressed_
		if Input.is_action_pressed("sprint"):

			# Start "sprinting"
			to_sprinting()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:

		# Start "standing"		
		to_standing()

	# The player must be moving
	else:

		# Check if the player speed is slower than or equal to "walking"
		if player.speed_current <= player.speed_walking:

			# Start "walking"
			to_walking()

		# Check if the player speed is faster than "running" but slower than or equal to "sprinting"
		elif player.speed_running < player.speed_current and player.speed_current <= player.speed_sprinting:

			# Start "sprinting"
			to_sprinting()

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
			if player.animation_player.current_animation != player.animation_running_holding_rifle:

				# Play the "running, holding rifle" animation
				player.animation_player.play(player.animation_running_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_running_holding_tool:

				# Play the "running, holding a tool" animation
				player.animation_player.play(player.animation_running_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_running:

				# Play the "running" animation
				player.animation_player.play(player.animation_running)


## Start "running".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	States.current_state = States.State.RUNNING

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


## State.RUNNING -> State.CROUCHING
func to_crouching() -> void:

	# Stop "running"
	stop()

	# Start "crouching"
	$"../Crouching".start()


## State.RUNNING -> State.JUMPING
func to_jumping() -> void:

	# Stop "running"
	stop()

	# Start "jumping"
	$"../Jumping".start()


## State.RUNNING -> State.STANDING
func to_standing() -> void:

	# Stop "running"
	stop()

	# Start "standing"
	$"../Standing".start()


## State.RUNNING -> State.SPRINTING
func to_sprinting() -> void:

	# Stop "running"
	stop()

	# Start "sprinting"
	$"../Sprinting".start()


## State.RUNNING -> State.WALKING
func to_walking() -> void:

	# Stop "running"
	stop()

	# Start "walking"
	$"../Walking".start()
