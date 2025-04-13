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
const NODE_NAME := "Standing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# Web fix - Input is required before the mouse can be captured so onready wont work
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		# [crouch] button just _pressed_ and crouching is enabled
		if event.is_action_pressed("crouch") and player.enable_crouching:

			# Start "crouching"
			transition(NODE_NAME, "Crouching")

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			transition(NODE_NAME, "Jumping")

		# [left-kick] button _pressed_
		if event.is_action_pressed("left_kick"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is not "holding a rifle" (and kicking is enabled)
					if !player.is_holding_rifle and player.enable_kicking:

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

		# [right-kick] button _pressed_
		if event.is_action_pressed("right_kick"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "crouching" and is "on floor"
				if !player.is_crouching and player.is_on_floor():

					# Check if the player is not "holding a rifle" (and kicking is enabled)
					if !player.is_holding_rifle and player.enable_kicking:

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

		# [left-punch] button just _pressed_
		if event.is_action_pressed("left_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "holding a fishing rod"
				if player.is_holding_fishing_rod:

					# Flag the player as "reeling"
					player.is_reeling = true

				# Check if the player is "holding a rifle"
				elif player.is_holding_rifle:

					# Flag the player as "aiming"
					player.is_aiming = true

				# The player must be unarmed
				else:

					# Check if punching is enabled
					if player.enable_punching:

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

		# [left-punch] button just _released_
		if event.is_action_released("left_punch"):

			# Check if the player is "holding a fishing rod"
			if player.is_holding_fishing_rod:

				# Flag the player as not "reeling"
				player.is_reeling = false

			# Check if the player is "holding a rifle"
			elif player.is_holding_rifle:

				# Flag the player as not "aiming"
				player.is_aiming = false

		# [right-punch] button just _pressed_
		if event.is_action_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "holding a fishing rod"
				if player.is_holding_fishing_rod:

					# Flag the player as "casting"
					player.is_casting = true

				# Check if the player is "holding a rifle"
				elif player.is_holding_rifle:

					# Flag the player as is "firing"
					player.is_firing = true

					# Delay execution
					await get_tree().create_timer(0.3).timeout

					# Flag the player as is not "firing"
					player.is_firing = false

				# The player must be unarmed
				else:

					# Check if punching is enabled
					if player.enable_punching:

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

		# [right-punch] button just _released_
		if event.is_action_released("right_punch"):

			# Check if the player is "holding a fishing rod"
			if player.is_holding_fishing_rod:

				# Flag the player as not "casting"
				player.is_casting = false


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# [crouch] button _pressed_, crouching is enabled, and not already "crouching"
	if Input.is_action_pressed("crouch") and player.enable_crouching and !player.is_crouching:

		# Check if the animation player is not locked
		if !player.is_animation_locked:

			# Start "crouching"
			transition(NODE_NAME, "Crouching")

	# Check if the player is moving
	if player.velocity != Vector3.ZERO or player.virtual_velocity != Vector3.ZERO:

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

			# Start "sprinting"
			transition(NODE_NAME, "Sprinting")

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

				# Get the held fishing rod's animation player
				var fishing_rod_animation_player = player.held_item_mount.get_node("FishingRod/AnimationPlayer")

				# Check if the animation player is not already playing the appropriate animation
				if fishing_rod_animation_player.current_animation != "Take 001":

					# Play the "reeling" animation
					fishing_rod_animation_player.play("Take 001")

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

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_STANDING_HOLDING_TOOL:

				# Play the "standing, holding tool" animation
				player.animation_player.play(ANIMATION_STANDING_HOLDING_TOOL)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_STANDING:

				# Play the "standing idle" animation
				player.animation_player.play(ANIMATION_STANDING)


## Start "standing".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.STANDING

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
