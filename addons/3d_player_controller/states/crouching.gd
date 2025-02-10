extends BaseState

const animation_crouching = "Crouching_Idle"
const animation_crouching_aiming_rifle = "Rifle_Aiming_Idle_Crouching"
const animation_crouching_firing_rifle = "Rifle_Firing_Crouching"
const animation_crouching_holding_rifle = "Rifle_Idle_Crouching"
const animation_crouching_move = "Sneaking_In_Place"
const animation_crouching_move_holding_rifle = "Rifle_Walk_Crouching"
const animation_crouching_holding_tool = "Tool_Idle_Crouching"
const animation_punching_low_left = "Punching_Low_Left"
const animation_punching_low_right = "Punching_Low_Right"
var node_name = "Crouching"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:

			# Start "jumping"
			transition(node_name, "Jumping")

		# [left-punch] button just _pressed_
		if event.is_action_pressed("left_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "holding a rifle"
				if player.is_holding_rifle:

					# Flag the player as is "aiming"
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
						if player.animation_player.current_animation != animation_punching_low_left:

							# Play the "punching low, left" animation
							player.animation_player.play(animation_punching_low_left)

							# Check the punch hits something
							player.check_punch_collision()

		# [left-punch] button just _released_
		if event.is_action_released("left_punch"):

			# Check if the player is "holding a rifle"
			if player.is_holding_rifle:

				# Flag the player as not "aiming"
				player.is_aiming = false

		# [right-punch] button just _pressed_
		if event.is_action_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not "holding a rifle"
				if !player.is_holding_rifle:

					# Check if punching is enabled
					if player.enable_punching:

						# Flag the animation player as locked
						player.is_animation_locked = true

						# Flag the player as "punching with their right arm"
						player.is_punching_right = true

						# Check if the animation player is not already playing the appropriate animation
						if player.animation_player.current_animation != animation_punching_low_right:

							# Play the "punching low, right" animation
							player.animation_player.play(animation_punching_low_right)

							# Check the punch hits something
							player.check_punch_collision()

		# [right-punch] button just _pressed_
		if event.is_action_pressed("right_punch"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is "holding a rifle"
				if player.is_holding_rifle:

					# Flag the player as is "firing"
					player.is_firing = true

					# Delay execution
					await get_tree().create_timer(0.3).timeout

					# Flag the player as is not "firing"
					player.is_firing = false


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is moving
	if player.velocity != Vector3.ZERO or player.virtual_velocity != Vector3.ZERO:
	
		# Start "crawling"
		transition(node_name, "Crawling")

	# [crouch] button not _pressed_
	if !Input.is_action_pressed("crouch"):

		# Check if the animation player is not locked
		if !player.is_animation_locked:

			# Stop "crouching"
			transition(node_name, "Standing")

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
				if player.animation_player.current_animation != animation_crouching_firing_rifle:

					# Play the "crouching, firing rifle" animation
					player.animation_player.play(animation_crouching_firing_rifle)

			# Check if the player is "aiming"
			elif player.is_aiming:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != animation_crouching_aiming_rifle:

					# Play the "crouching, aiming a rifle" animation
					player.animation_player.play(animation_crouching_aiming_rifle)

			# The player must be "idle"
			else:

				# Check if the animation player is not already playing the appropriate animation
				if player.animation_player.current_animation != animation_crouching_holding_rifle:

					# Play the "crouching idle, holding rifle" animation
					player.animation_player.play(animation_crouching_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_crouching_holding_tool:

				# Play the "crouching, holding tool" animation
				player.animation_player.play(animation_crouching_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_crouching:

				# Play the "crouching" animation
				player.animation_player.play(animation_crouching)


## Start "crouching".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.CROUCHING

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
