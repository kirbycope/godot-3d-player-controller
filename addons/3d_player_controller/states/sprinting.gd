extends BaseState

const ANIMATION_SPRINTING := "Sprinting_In_Place" + "/mixamo_com"
const ANIMATION_SPRINTING_HOLDING_RIFLE := "Rifle_Sprinting_In_Place" + "/mixamo_com"
const ANIMATION_SPRINTING_HOLDING_TOOL := "Tool_Sprinting_In_Place" + "/mixamo_com"
const NODE_NAME := "Sprinting"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			transition(NODE_NAME, "Jumping")

		# [sprint] button just _released_
		if event.is_action_released("sprint"):

			# Start "standing"
			transition(NODE_NAME, "Standing")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:

		# Start "standing"
		transition(NODE_NAME, "Standing")

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
			if player.animation_player.current_animation != ANIMATION_SPRINTING_HOLDING_RIFLE:

				# Play the "sprinting, holding a rifle" animation
				player.animation_player.play(ANIMATION_SPRINTING_HOLDING_RIFLE)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_SPRINTING:

				# Play the "sprinting" animation
				player.animation_player.play(ANIMATION_SPRINTING)


## Start "sprinting".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SPRINTING

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
