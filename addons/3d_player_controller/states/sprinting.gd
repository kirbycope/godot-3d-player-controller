extends BaseState

const animation_sprinting = "Sprinting_In_Place"
const animation_sprinting_holding_rifle = "Rifle_Sprinting_In_Place"
const animation_sprinting_holding_tool = "Tool_Sprinting_In_Place"
var node_name = "Sprinting"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			transition(node_name, "Jumping")

		# [sprint] button just _released_
		if event.is_action_released("sprint"):

			# Start "standing"
			transition(node_name, "Standing")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is not moving
	if player.velocity == Vector3.ZERO and player.virtual_velocity == Vector3.ZERO:

		# Start "standing"
		transition(node_name, "Standing")

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
			if player.animation_player.current_animation != animation_sprinting_holding_rifle:

				# Play the "sprinting, holding a rifle" animation
				player.animation_player.play(animation_sprinting_holding_rifle)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_sprinting:

				# Play the "sprinting" animation
				player.animation_player.play(animation_sprinting)


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
