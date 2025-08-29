extends BaseState

const ANIMATION_JUMPING := "Falling_Idle" + "/mixamo_com"
const ANIMATION_JUMPING_HOLDING_RIFLE := "Rifle_Falling_Idle" + "/mixamo_com"
const ANIMATION_JUMPING_HOLDING_TOOL := "Tool_Falling_Idle" + "/mixamo_com"
const NODE_NAME := "Jumping"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓐ/[Space] _pressed_ and double jumping is enabled -> Start "double jumping"
		if event.is_action_pressed("button_0") and player.enable_double_jump and !player.is_double_jumping:
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Check if the player is not on the ground
				if !player.is_on_floor():
					# Set the player's vertical velocity
					player.velocity.y = player.jump_velocity
					# Set the "double jumping" flag
					player.is_double_jumping = true

		# Ⓐ/[Space] _pressed_ and flying is enabled --> Start "flying"
		if event.is_action_pressed("button_0") and player.enable_flying and !player.is_flying and !player.is_on_floor():
			# Check if the animation player is not locked
			if !player.is_animation_locked:
				# Start "flying"
				transition(NODE_NAME, "Flying")
		# Ⓐ/[Space] _pressed_ and paragliding is enabled --> Start "paragliding"
		if event.is_action_pressed("button_0") and player.enable_paragliding and !player.is_paragliding and !player.is_on_floor():
			# Check if the player has a glider
			if player.head_mount.get_child_count() > 0:
				# Check if the animation player is not locked
				if !player.is_animation_locked:
					# Start "paragliding"
					transition(NODE_NAME, "Paragliding")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Check if the player is not canceling a climb or hang
		if !Input.is_action_pressed("button_3"):
			# Check the eyeline for a ledge to grab.
			if !player.raycast_top.is_colliding() and player.raycast_high.is_colliding():
				# Get the collision object
				var collision_object = player.raycast_high.get_collider()
				# Only proceed if the collision object is not in the "held" group and not a player
				if !collision_object.is_in_group("held") and !collision_object is CharacterBody3D:
					# Start "hanging"
					transition(NODE_NAME, "Hanging")
	# Check if the player is falling
	if player.velocity.y < 0.0:
		# Check if "climbing" is enabled and the player is not currently climbing:
		if player.enable_climbing and !player.is_climbing:
			# Check if the player is facing a climbable surface
			if player.raycast_middle.is_colliding():
				# Start "climbing"
				transition(NODE_NAME, "Climbing")
				return
		# Start "falling"
		transition(NODE_NAME, "Falling")
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
			if player.animation_player.current_animation != ANIMATION_JUMPING_HOLDING_RIFLE:
				# Play the "jumping, holding a rifle" animation
				player.animation_player.play(ANIMATION_JUMPING_HOLDING_RIFLE)
		# Check if the player is "holding a tool"
		elif player.is_holding_tool:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_JUMPING_HOLDING_TOOL:
				# Play the "jumping, holding a tool" animation
				player.animation_player.play(ANIMATION_JUMPING_HOLDING_TOOL)
		# The player must be unarmed
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_JUMPING:
				# Play the "jumping" animation
				player.animation_player.play(ANIMATION_JUMPING)


## Start "jumping".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.JUMPING
	# Flag the player as "jumping"
	player.is_jumping = true
	# Flag the player as not "double jumping"
	player.is_double_jumping = false
	# Scale the vertical velocity based on the player's size
	var jump_velocity_scaled = player.jump_velocity * player.scale.y
	# Set the player's vertical velocity
	player.velocity.y = jump_velocity_scaled


## Stop "jumping".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "jumping"
	player.is_jumping = false
