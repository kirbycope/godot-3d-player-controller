extends BaseState

const ANIMATION_SKATEBOARDING_FAST := "Skateboarding_Fast_In_Place" + "/mixamo_com"
const ANIMATION_SKATEBOARDING_NORMAL := "Skateboarding_In_Place" + "/mixamo_com"
const ANIMATION_SKATEBOARDING_SLOW := "Skateboarding_Slow_In_Place" + "/mixamo_com"
const NODE_NAME := "Skateboarding"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓨ/[Ctrl] _pressed_ -> Slow down
		if event.is_action_pressed("button_3"):
			# Check if the player is on the ground
			if player.is_on_floor():
				# Flag the player as "crouching"
				player.is_crouching = true
				# Set the player's speed
				player.speed_current = player.speed_crawling
		# Ⓨ/[Ctrl] _released_ -> Resume normal speed
		if event.is_action_released("button_3"):
			# Flag the player as not "crouching"
			player.is_crouching = false
			# Set the player's speed
			player.speed_current = player.speed_running
		# Ⓐ/[Space] _pressed_ -> Jump
		if event.is_action_pressed("button_0"):
			# Check if the player is on the ground
			if player.is_on_floor():
				# Flag the player as "jumping"
				player.is_jumping = true
				# Set the player's vertical velocity
				player.velocity.y = player.jump_velocity
		# (D-Pad Down)/[Q] _pressed_ -> Drop skateboard
		if event.is_action_pressed("button_13"):
			# Reparent the skateboard from the player to current scene
			player.reparent_equipped_foot_items()
			# Check if the player is on the ground
			if player.is_on_floor():
				# Start standing
				transition(NODE_NAME, "Standing")
			# The player must not be on the ground
			else:
				# Start Falling
				transition(NODE_NAME, "Falling")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is not "skateboarding"
	if !player.is_skateboarding:
		# Start "standing"
		transition(NODE_NAME, "Standing")
	# [sprint] button _pressed_
	if Input.is_action_pressed("button_1"):
		# Set the player's speed
		player.speed_current = player.speed_sprinting
	# [sprint] button _release_
	if Input.is_action_just_released("button_1"):
		# Set the player's speed
		player.speed_current = player.speed_running
	# Check if the player is "skateboarding"
	if player.is_skateboarding:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Set the animation player to the default speed
		player.animation_player.speed_scale = 1.0
		# Check if the player is moving
		if player.velocity != Vector3.ZERO:
			# Check if the player is grounded
			if player.velocity.y == 0:
				# Check if the player is slower than or equal to "walking"
				if 0.0 < player.speed_current and player.speed_current <= player.speed_walking:
					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != ANIMATION_SKATEBOARDING_SLOW:
						# Play the "slow skateboarding" animation
						player.animation_player.play(ANIMATION_SKATEBOARDING_SLOW)
				# Check if the player speed is faster than "walking" but slower than or equal to "running"
				elif player.speed_walking < player.speed_current and player.speed_current <= player.speed_running:
					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != ANIMATION_SKATEBOARDING_NORMAL:
						# Play the "normal skateboarding" animation
						player.animation_player.play(ANIMATION_SKATEBOARDING_NORMAL)
				# Check if the player speed is faster than "running"
				elif player.speed_running < player.speed_current:
					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != ANIMATION_SKATEBOARDING_FAST:
						# Play the "slow skateboarding" animation
						player.animation_player.play(ANIMATION_SKATEBOARDING_FAST)
			# The player must be not grounded
			else:
				# Flag the player as "jumping"
				player.is_jumping = true
		# The player must not be moving
		else:
			# Play the "slow skateboarding" animation
			player.animation_player.play(ANIMATION_SKATEBOARDING_SLOW)
			# Slow down the animation player
			player.animation_player.speed_scale = 0.5


## Start "skateboarding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.SKATEBOARDING
	# Flag the player as "skateboarding"
	player.is_skateboarding = true


## Stop "skateboarding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# [Re]Set the player animation speed
	player.animation_player.speed_scale = 1.0
	# [Re]Set audio player pitch
	player.audio_player.pitch_scale = 1.0
	# Flag the player as not "skateboarding"
	player.is_skateboarding = false
