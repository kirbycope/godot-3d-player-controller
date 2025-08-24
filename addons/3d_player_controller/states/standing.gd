extends BaseState

const ANIMATION_STANDING := "Standing_Idle" + "/mixamo_com"
const ANIMATION_STANDING_AIMING_RIFLE := "Rifle_Aiming_Idle" + "/mixamo_com"
const ANIMATION_STANDING_FIRING_RIFLE := "Rifle_Firing" + "/mixamo_com"
const ANIMATION_STANDING_CASTING_FISHING_ROD := "Fishing_Cast" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_FISHING_ROD := "Fishing_Idle" + "/mixamo_com"
const ANIMATION_STANDING_REELING_FISHING_ROD := "Fishing_Reel" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_RIFLE := "Rifle_Low_Idle" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_TOOL := "Tool_Standing_Idle" + "/mixamo_com"
const ANIMATION_STANDING_KICKING_LOW_LEFT := "Kicking_Low_Left" + "/mixamo_com"
const ANIMATION_STANDING_KICKING_LOW_RIGHT := "Kicking_Low_Right" + "/mixamo_com"
const ANIMATION_STANDING_PUNCHING_HIGH_LEFT := "Punching_High_Left" + "/mixamo_com"
const ANIMATION_STANDING_PUNCHING_HIGH_RIGHT := "Punching_High_Right" + "/mixamo_com"
const ANIMATION_STANDING_PUNCHING_LOW_LEFT := "Punching_Low_Left" + "/mixamo_com"
const ANIMATION_STANDING_PUNCHING_LOW_RIGHT := "Punching_Low_Right" + "/mixamo_com"
const ANIMATION_STANDING_USING := "Button_Pushing" + "/mixamo_com"
const ANIMATION_STANDING_SWINGING_LEFT := "Standing_Melee_Attack_Downward_Left" + "/mixamo_com"
const ANIMATION_STANDING_SWINGING_RIGHT := "Standing_Melee_Attack_Downward_Right" + "/mixamo_com"
const ANIMATION_STANDING_BLOCKING_LEFT := "Standing_Block_Idle_Left" + "/mixamo_com"
const ANIMATION_STANDING_BLOCKING_RIGHT := "Standing_Block_Idle_Right" + "/mixamo_com"
const NODE_NAME := "Standing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# Web fix - Input is required before the mouse can be captured so onready wont work
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		# Ⓐ/[Space] _pressed_ and jumping is enabled -> Start "jumping"
		if event.is_action_pressed("button_0") and player.enable_jumping and !player.is_animation_locked:
			# Start "jumping"
			transition(NODE_NAME, "Jumping")

		# Ⓑ/[Shift] _pressed_ and next to a flipped vehicle -> Flip the vehicle
		if event.is_action_pressed("button_1") and player.raycast_middle.is_colliding():
			var collider = player.raycast_middle.get_collider()
			# Check if the collider is a vehicle
			if collider is VehicleBody3D:
				# Check if the vehicle has a raycast
				if collider.has_node("RayCast3D"):
					# Check if the raycast is not colliding
					if !collider.get_node("RayCast3D").is_colliding():
						# Check if the vehicle has a method to flip
						if collider.has_method("flip_vehicle"):
							# Call the flip method
							collider.flip_vehicle()

		# Ⓧ/[E] _pressed_ (and the middle raycast is colliding)
		if event.is_action_pressed("button_2") and player.raycast_use.is_colliding():
			# Check that the collider is usable
			if player.raycast_use.get_collider().is_in_group("Usable"):
				# Flag the player as "using"
				player.is_using = true

		# Ⓨ/[Ctrl] _pressed_ and crouching is enabled -> Start "crouching"
		if event.is_action_pressed("button_3") and player.enable_crouching and !player.is_animation_locked:
			# Start "crouching"
			transition(NODE_NAME, "Crouching")

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
					if player.animation_player.current_animation != ANIMATION_STANDING_PUNCHING_HIGH_LEFT:
							# Play the "punching high, left" animation
							player.animation_player.play(ANIMATION_STANDING_PUNCHING_HIGH_LEFT)
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
					if player.animation_player.current_animation != ANIMATION_STANDING_PUNCHING_HIGH_RIGHT:
							# Play the "punching high, right" animation
							player.animation_player.play(ANIMATION_STANDING_PUNCHING_HIGH_RIGHT)
							# Check the punch hits something
							player.check_punch_collision()

		# 🄻2/[Mouse-Forward] _pressed_ and kicking is enabled -> Start "kicking" (left leg)
		if event.is_action_pressed("button_6") and player.enable_kicking:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():
					# Check if the player is not "holding a rifle"
					if !player.is_holding_rifle:
						# Flag the animation player as locked
						player.is_animation_locked = true
						# Flag the player as "kicking with their left leg"
						player.is_kicking_left = true
						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != ANIMATION_STANDING_KICKING_LOW_LEFT:
							# Play the "kicking low, left" animation
							player.animation_player.play(ANIMATION_STANDING_KICKING_LOW_LEFT)
							# Check the kick hits something
							player.check_kick_collision()

		# 🅁2/[Mouse-Backward] _pressed_ and kicking is enabled -> Start "kicking" (right leg)
		if event.is_action_pressed("button_7") and player.enable_kicking:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():
					# Check if the player is not "holding a rifle"
					if !player.is_holding_rifle:
						# Flag the animation player as locked
						player.is_animation_locked = true
						# Flag the player as "kicking with their right leg"
						player.is_kicking_right = true
						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != ANIMATION_STANDING_KICKING_LOW_RIGHT:
							# Play the "kicking low, right" animation
							player.animation_player.play(ANIMATION_STANDING_KICKING_LOW_RIGHT)
							# Check the kick hits something
							player.check_kick_collision()

		# 🄻2/[R-Click] _pressed_ and the player is "holding a rifle" -> Start "aiming"
		if controls.current_input_type == controls.InputType.KEYBOARD_MOUSE and event.is_action_pressed("button_5") and player.is_holding_rifle \
		or event.is_action_pressed("button_6") and player.is_holding_rifle:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as "aiming"
				player.is_aiming = true

		# 🄻2/[R-Click] _released_ and the player is "holding a rifle" -> Stop "aiming"
		if controls.current_input_type == controls.InputType.KEYBOARD_MOUSE and event.is_action_released("button_5") and player.is_holding_rifle \
		or event.is_action_released("button_6") and player.is_holding_rifle:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as not "aiming"
				player.is_aiming = false

		# 🅁2/[L-Click] _pressed_ the player is "holding a rifle" -> Start "firing"
		if controls.current_input_type == controls.InputType.KEYBOARD_MOUSE and event.is_action_pressed("button_4") and player.is_holding_rifle \
		or event.is_action_pressed("button_7") and player.is_holding_rifle:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as is "firing"
				player.is_firing = true
				# Delay execution
				await get_tree().create_timer(0.3).timeout
				# Flag the player as is not "firing"
				player.is_firing = false

		# 🄻1/[L-Click] _pressed_ and the player is "holding a fishing rod" -> Start "casting"
		if event.is_action_pressed("button_4") and player.is_holding_fishing_rod:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as "casting"
				player.is_casting = true

		# 🄻1/[L-Click] _released_ and player is holding a fishing rod -> Stop "casting"
		if event.is_action_released("button_4") and player.is_holding_fishing_rod:
			# Flag the player as not "casting"
			player.is_casting = false

		# 🅁1/[R-Click] _pressed_ and player is "holding a fishing rod" -> Start "reeling"
		if event.is_action_pressed("button_5") and player.is_holding_fishing_rod:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as "reeling"
				player.is_reeling = true

		# 🅁1/[R-Click] _released_ and the player is "holding a fishing rod" -> Stop "reeling"
		if event.is_action_released("button_5") and player.is_holding_fishing_rod:
			# Flag the player as not "reeling"
			player.is_reeling = false

		# 🄻1/[L-Click] _pressed_ and player is "holding a tool" -> Start "blocking" (left arm)
		if event.is_action_pressed("button_4") and player.is_holding_tool:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as "blocking" (left arm)
				player.is_blocking_left = true
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_BLOCKING_LEFT:
					# Play the "blocking left" animation
					player.animation_player.play(ANIMATION_STANDING_BLOCKING_LEFT)

		# 🄻1/[L-Click] _released_ and player is "holding a tool" -> Stop "blocking" (left arm)
		if event.is_action_released("button_4") and player.is_holding_tool:
			# Flag the player as not "blocking" (left arm)
			player.is_blocking_left = false

		# 🅁1/[R-Click] _pressed_ and player is "holding a tool" -> Start "swinging" (right arm)
		if event.is_action_pressed("button_5") and player.is_holding_tool:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the animation player as locked
				player.is_animation_locked = true
				# Flag the player as "swinging" (right arm)
				player.is_swinging_right = true
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_SWINGING_RIGHT:
					# Play the "swinging right" animation
					player.animation_player.play(ANIMATION_STANDING_SWINGING_RIGHT)
				# Check the tool hits something
				player.check_tool_collision()


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓨ/[Ctrl] _pressed_ and crouching is enabled -> Start "crouching"
		if Input.is_action_pressed("button_3") and player.enable_crouching and !player.is_crouching:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Start "crouching"
				transition(NODE_NAME, "Crouching")

		# 🄻1/[L-Click] _pressed_ and player is "holding a tool" -> Start "blocking" (left arm)
		if Input.is_action_pressed("button_4") and player.is_holding_tool and !player.is_blocking_left:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Flag the player as "blocking" (left arm)
				player.is_blocking_left = true
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_BLOCKING_LEFT:
					# Play the "blocking left" animation
					player.animation_player.play(ANIMATION_STANDING_BLOCKING_LEFT)

		# 🄻1/[L-Click] just _released_ and player is "holding a tool" -> Stop "blocking" (left arm)
		if Input.is_action_just_released("button_4") and player.is_holding_tool:
			# Flag the player as not "blocking" (left arm)
			player.is_blocking_left = false

		# Check if the player is moving
		if player.velocity != Vector3.ZERO or player.virtual_velocity != Vector3.ZERO:
			# Check if the player is not on a floor
			if !player.is_on_floor() and !player.raycast_below.is_colliding():
				# Start "falling"
				transition(NODE_NAME, "Falling")

			# Check if the player is slower than or equal to "walking"
			if 0.0 < player.speed_current and player.speed_current <= player.speed_walking:
				# Start "walking"
				transition(NODE_NAME, "Walking")

			# Check if the player speed is faster than "walking" but slower than or equal to "running"
			elif player.speed_walking < player.speed_current and player.speed_current <= player.speed_running:
				# Start "running"
				transition(NODE_NAME, "Running")

			# Check if the player speed is faster than "running" but slower than or equal to "sprinting"
			elif player.speed_running < player.speed_current and player.speed_current <= player.speed_sprinting:
				# Check if sprinting is enabled
				if player.enable_sprinting:
					# Start "sprinting"
					transition(NODE_NAME, "Sprinting")

		# Check if the player is not moving but input is pressed and blocked by obstacle
		elif not player.is_animation_locked and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")):
			# Check if there is something in front of the player
			if player.raycast_middle.is_colliding() or player.raycast_high.is_colliding():
				# Start "pushing"
				transition(NODE_NAME, "Pushing")

	# Check if the player is "standing"
	if player.is_standing:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the player is "holding a fishing rod"
		if player.is_holding_fishing_rod:
			# Check if the player is "casting"
			if player.is_casting:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_CASTING_FISHING_ROD:
					# Play the "standing, casting fishing rod" animation
					player.animation_player.play(ANIMATION_STANDING_CASTING_FISHING_ROD)

			# Check if the player is "reeling"
			elif player.is_reeling:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_REELING_FISHING_ROD:
					# Play the "standing, holding reeling rod" animation
					player.animation_player.play(ANIMATION_STANDING_REELING_FISHING_ROD)

			# The player must be "idle"
			else:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_HOLDING_FISHING_ROD:
					# Play the "standing, holding fishing rod" animation
					player.animation_player.play(ANIMATION_STANDING_HOLDING_FISHING_ROD)

		# Check if the player is "holding a rifle"
		elif player.is_holding_rifle:
			# Check if the player is "firing"			
			if player.is_firing:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_FIRING_RIFLE:
					# Play the "standing, firing rifle" animation
					player.animation_player.play(ANIMATION_STANDING_FIRING_RIFLE)

			# Check if the player is "aiming"
			elif player.is_aiming:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_AIMING_RIFLE:
					# Play the "standing, aiming rifle" animation
					player.animation_player.play(ANIMATION_STANDING_AIMING_RIFLE)

			# The player must be "idle"
			else:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_HOLDING_RIFLE:
					# Play the "standing idle, holding rifle" animation
					player.animation_player.play(ANIMATION_STANDING_HOLDING_RIFLE)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:
			# Check if the player is "blocking" (left arm)
			if player.is_blocking_left:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_BLOCKING_LEFT:
					# Play the "standing, blocking left" animation
					player.animation_player.play(ANIMATION_STANDING_BLOCKING_LEFT)

			# Check if the player is "blocking" (right arm)
			elif player.is_blocking_right:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_BLOCKING_RIGHT:
					# Play the "standing, blocking right" animation
					player.animation_player.play(ANIMATION_STANDING_BLOCKING_RIGHT)

			# Check if the player is "swinging" (left arm)
			elif player.is_swinging_left:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_SWINGING_LEFT:
					# Play the "standing, swinging left" animation
					player.animation_player.play(ANIMATION_STANDING_SWINGING_LEFT)

			# Check if the player is "swinging" (right arm)
			elif player.is_swinging_right:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_SWINGING_RIGHT:
					# Play the "standing, swinging right" animation
					player.animation_player.play(ANIMATION_STANDING_SWINGING_RIGHT)


			# The player must be "idle"
			else:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_HOLDING_TOOL:
					# Play the "standing, holding tool" animation
					player.animation_player.play(ANIMATION_STANDING_HOLDING_TOOL)

		# The player must be unarmed
		else:
			# Check if the player is "punching" (left arm)
			if player.is_punching_left:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_PUNCHING_HIGH_LEFT:
					# Play the "punching high, left" animation
					player.animation_player.play(ANIMATION_STANDING_PUNCHING_HIGH_LEFT)

			# Check if the player is "punching" (right arm)
			elif player.is_punching_right:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_PUNCHING_HIGH_RIGHT:
					# Play the "punching high, right" animation
					player.animation_player.play(ANIMATION_STANDING_PUNCHING_HIGH_RIGHT)

			# Check if the player is "kicking" (left leg)
			elif player.is_kicking_left:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_KICKING_LOW_LEFT:
					# Play the "kicking low, left" animation
					player.animation_player.play(ANIMATION_STANDING_KICKING_LOW_LEFT)

			# Check if the player is "kicking" (right leg)
			elif player.is_kicking_right:
				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != ANIMATION_STANDING_KICKING_LOW_RIGHT:
					# Play the "kicking low, right" animation
					player.animation_player.play(ANIMATION_STANDING_KICKING_LOW_RIGHT)

			# Check if the player is "using"
			elif player.is_using:
				# Play the "standing using" animation
				player.animation_player.play(ANIMATION_STANDING_USING)

				# Flag the animation player as locked
				player.is_animation_locked = true

				# Delay execution
				await get_tree().create_timer(3.3).timeout

				# Flag the animation player no longer locked
				player.is_animation_locked = false

				# Flag the player as no longer using
				player.is_using = false

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_STANDING:
				# Play the "standing idle" animation
				player.animation_player.play(ANIMATION_STANDING)


## Start "standing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = STATES.State.STANDING

	# Flag the player as "standing"
	player.is_standing = true

	# Set the player's speed
	player.speed_current = 0.0

	# Set the player's velocity
	player.velocity = Vector3.ZERO

## Stop "standing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "standing"
	player.is_standing = false

	# Reset player state
	player.is_using = false
	# Reset player unarmed state
	player.is_kicking_left = false
	player.is_kicking_right = false
	player.is_punching_left = false
	player.is_punching_right = false
	# Reset player fishing state
	player.is_casting = false
	player.is_reeling = false
	# Reset player shooting state
	player.is_aiming = false
	player.is_firing = false
	# Reset player tool state
	player.is_blocking_left = false
	player.is_blocking_right = false
	player.is_swinging_left = false
	player.is_swinging_right = false
