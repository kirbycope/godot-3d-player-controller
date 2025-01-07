extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			to_jumping()

		# [sprint] button just _released_
		if Input.is_action_just_released("sprint"):

			# Start "standing"
			to_standing()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:

		# Start "standing"
		to_standing()

	# Check if the player is "sprinting"
	if player.is_sprinting:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_sprinting_holding_rifle:

				# Play the "sprinting, holding a rifle" animation
				player.animation_player.play(player.animation_sprinting_holding_rifle)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_sprinting:

				# Play the "sprinting" animation
				player.animation_player.play(player.animation_sprinting)


## Start "sprinting".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	States.current_state = States.State.SPRINTING

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


## State.SPRINTING -> State.JUMPING
func to_jumping() -> void:

	# Stop "sprinting"
	stop()

	# Start "jumping"
	$"../Jumping".start()


## State.SPRINTING -> State.RUNNING
func to_running() -> void:

	# Stop "sprinting"
	stop()

	# Start "running"
	$"../Running".start()


## State.SPRINTING -> State.STANDING
func to_standing() -> void:

	# Stop "sprinting"
	stop()

	# Start "standing"
	$"../Standing".start()
