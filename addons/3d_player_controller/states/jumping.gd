extends BaseState

const animation_jumping = "Falling_Idle"
const animation_jumping_holding_rifle = "Rifle_Falling_Idle"
const animation_jumping_holding_tool = "Tool_Falling_Idle"
var node_name = "Jumping"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [jump] button just _pressed_
		if event.is_action_pressed("jump"):

			# Check if the animation player is not locked
			if !player.is_animation_locked:

				# Check if the player is not on the ground
				if !player.is_on_floor():

					# Check if "double jump" is enabled and the player is not currently double-jumping
					if player.enable_double_jump and !player.is_double_jumping:

						# Set the player's vertical velocity
						player.velocity.y = player.jump_velocity

						# Set the "double jumping" flag
						player.is_double_jumping = true
					
					# Check if "flying" is enabled and the player is not currently flying
					elif player.enable_flying and !player.is_flying:

						# Start "flying"
						transition(node_name, "Flying")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check the eyeline for a ledge to grab.
	if !player.raycast_top.is_colliding() and player.raycast_high.is_colliding():

		# Get the collision object
		var collision_object = player.raycast_high.get_collider()

		# Only proceed if the collision object is not in the "held" group and not a player
		if !collision_object.is_in_group("held") and !collision_object is CharacterBody3D:

			# Start "hanging"
			transition(node_name, "Hanging")

	# Check if the player is falling
	if player.velocity.y < 0.0:

		# Start "falling"
		transition(node_name, "Falling")

	# Check if the player is "jumping"
	if player.is_jumping:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_jumping_holding_rifle:

				# Play the "jumping, holding a rifle" animation
				player.animation_player.play(animation_jumping_holding_rifle)

		# Check if the player is "holding a tool"
		elif player.is_holding_tool:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_jumping_holding_tool:

				# Play the "jumping, holding a tool" animation
				player.animation_player.play(animation_jumping_holding_tool)

		# The player must be unarmed
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_jumping:

				# Play the "jumping" animation
				player.animation_player.play(animation_jumping)


## Start "jumping".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.JUMPING

	# Flag the player as "jumping"
	player.is_jumping = true

	# Flag the player as not "grounded"
	player.is_grounded = false

	# Flag the player as not "double jumping"
	player.is_double_jumping = false

	# Set the player's vertical velocity
	player.velocity.y = player.jump_velocity


## Stop "jumping".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "jumping"
	player.is_jumping = false
