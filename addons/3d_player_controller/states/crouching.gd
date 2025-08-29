extends BaseState

const ANIMATION_CROUCHING := "Crouching_Idle" + "/mixamo_com"
const ANIMATION_CROUCHING_AIMING_RIFLE := "Rifle_Aiming_Idle_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_FIRING_RIFLE := "Rifle_Firing_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_HOLDING_RIFLE := "Rifle_Idle_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_MOVE := "Sneaking_In_Place" + "/mixamo_com"
const ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE := "Rifle_Walk_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_HOLDING_TOOL := "Tool_Idle_Crouching" + "/mixamo_com"
const ANIMATION_PUNCHING_LOW_LEFT := "Punching_Low_Left" + "/mixamo_com"
const ANIMATION_PUNCHING_LOW_RIGHT := "Punching_Low_Right" + "/mixamo_com"
const NODE_NAME := "Crouching"


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
		# 🄻2/[R-Click] _pressed_ and the player is "holding a rifle" -> Start "aiming"
		if controls.current_input_type == controls.InputType.KEYBOARD_MOUSE and event.is_action_pressed("button_5") and player.is_holding_rifle\
		or event.is_action_pressed("button_6") and player.is_holding_rifle:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as is "aiming"
				player.is_aiming = true
		# 🄻2/[R-Click] _released_ and the player is "holding a rifle" -> Stop "aiming"
		if controls.current_input_type == controls.InputType.KEYBOARD_MOUSE and event.is_action_released("button_5") and player.is_holding_rifle\
		or event.is_action_released("button_6") and player.is_holding_rifle:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as not "aiming"
				player.is_aiming = false
		# 🅁2/[L-Click] _pressed_ the player is "holding a rifle" -> Start "firing"
		if controls.current_input_type == controls.InputType.KEYBOARD_MOUSE and event.is_action_pressed("button_4") and player.is_holding_rifle\
		or event.is_action_pressed("button_7") and player.is_holding_rifle:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as is "firing"
				player.is_firing = true
				# Delay execution
				await get_tree().create_timer(0.3).timeout
				# Flag the player as is not "firing"
				player.is_firing = false
		# 🄻1/[L-Click] _pressed_ and punching is enabled -> Start "punching" (left arm)
		if event.is_action_pressed("button_4") and player.enable_punching:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Check if the player is not "holding a fishing rod", "holding a rifle", "holding a tool", and not holding any object
				if !player.is_holding_fishing_rod and !player.is_holding_rifle and !player.is_holding_tool and !player.is_holding:
					# Flag the animation player as locked
					player.is_animation_locked = true
					# Flag the player as "punching with their left arm"
					player.is_punching_left = true
					# Check if the animation player is not already playing the appropriate animation
					if player.animation_player.current_animation != ANIMATION_PUNCHING_LOW_LEFT:
						# Play the "punching low, left" animation
						player.animation_player.play(ANIMATION_PUNCHING_LOW_LEFT)
						# Check the punch hits something
						player.check_punch_collision()
		# 🅁1/[R-Click] _pressed_ and punching is enabled -> Start "punching" (right arm)
		if event.is_action_pressed("button_5") and player.enable_punching:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Check if the player is not "holding a fishing rod", "holding a rifle", "holding a tool", and not holding any object
				if !player.is_holding_fishing_rod and !player.is_holding_rifle and !player.is_holding_tool and !player.is_holding:
						# Flag the animation player as locked
						player.is_animation_locked = true
						# Flag the player as "punching with their right arm"
						player.is_punching_right = true
						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != ANIMATION_PUNCHING_LOW_RIGHT:
							# Play the "punching low, right" animation
							player.animation_player.play(ANIMATION_PUNCHING_LOW_RIGHT)
							# Check the punch hits something
							player.check_punch_collision()


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Check if the player is moving
		if player.velocity != Vector3.ZERO or player.virtual_velocity != Vector3.ZERO:
			# Start "crawling"
			transition(NODE_NAME, "Crawling")
		# Ⓨ/[Ctrl] not _pressed_
		if !Input.is_action_pressed("button_3"):
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Stop "crouching"
				transition(NODE_NAME, "Standing")
	# Check if the player is "crouching"
	if player.is_crouching:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:
			# Check if the player is "firing"			
			if player.is_firing:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_CROUCHING_FIRING_RIFLE:
					# Play the "crouching, firing rifle" animation
					player.animation_player.play(ANIMATION_CROUCHING_FIRING_RIFLE)
			# Check if the player is "aiming"
			elif player.is_aiming:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_CROUCHING_AIMING_RIFLE:
					# Play the "crouching, aiming a rifle" animation
					player.animation_player.play(ANIMATION_CROUCHING_AIMING_RIFLE)
			# The player must be "idle"
			else:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_CROUCHING_HOLDING_RIFLE:
					# Play the "crouching idle, holding rifle" animation
					player.animation_player.play(ANIMATION_CROUCHING_HOLDING_RIFLE)
		# Check if the player is "holding a tool"
		elif player.is_holding_tool:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_CROUCHING_HOLDING_TOOL:
				# Play the "crouching, holding tool" animation
				player.animation_player.play(ANIMATION_CROUCHING_HOLDING_TOOL)
		# The player must be unarmed
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_CROUCHING:
				# Play the "crouching" animation
				player.animation_player.play(ANIMATION_CROUCHING)


## Start "crouching".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.CROUCHING
	# Flag the player as "crouching"
	player.is_crouching = true
	# Set the player's movement speed
	player.speed_current = 0.0
	# Set CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2
	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position / 2


## Stop "crouching".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag player as not "crouching"
	player.is_crouching = false
	# Reset CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height
	# Reset CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position
