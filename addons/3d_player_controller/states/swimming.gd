extends BaseState

const ANIMATION_SWIMMING := "Swimming_In_Place" + "/mixamo_com"
const ANIMATION_TREADING_WATER := "Treading_Water" + "/mixamo_com"
const NODE_NAME := "Swimming"

# For smooth entry
var swimming_entry_target_y: float = 0.0
var swimming_entry_lerp_time: float = 0.0
const SWIMMING_ENTRY_LERP_DURATION: float = 0.08


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Smooth entry into water
		if swimming_entry_lerp_time > 0.0:
			swimming_entry_lerp_time -= _delta
			player.position.y = lerp(player.position.y, swimming_entry_target_y, min(1.0, _delta / SWIMMING_ENTRY_LERP_DURATION))
			if abs(player.position.y - swimming_entry_target_y) < 0.01 or swimming_entry_lerp_time <= 0.0:
				player.position.y = swimming_entry_target_y
				swimming_entry_lerp_time = 0.0
		# Ⓨ/[Ctrl] just _pressed_
		if Input.is_action_pressed("button_3"):
			# Decrement the player's vertical position
			player.position.y -= 0.01
		# Ⓐ/[Space] button just _pressed_
		if Input.is_action_pressed("button_0"):
			# Check if the player is swimming in a body of water
			if player.is_swimming_in:
				# Get the water level (top of water body)
				var water_top = player.is_swimming_in.get_parent().position.y + (player.is_swimming_in.get_child(0).shape.size.y / 2)
				# Get the player's new position (if it were incremented)
				var new_position = player.position.y + 0.01
				# Get the player's top position (position + height)
				var player_top = new_position + (player.collision_height * .75)
				# Check if the water is above the player
				if player_top <= water_top:
					# Increment the player's vertical position
					player.position.y = new_position
	# Check if the player is not "swimming"
	if !player.is_swimming:
		# Start "standing"
		transition(NODE_NAME, "Standing")
	# Check if the player is "swimming"
	if player.is_swimming:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the player is moving
		if player.velocity != Vector3.ZERO:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_SWIMMING:
				# Move the collison shape to match the player
				player.collision_shape.rotation_degrees.x = 90
				# Play the "swimming" animation
				player.animation_player.play(ANIMATION_SWIMMING)
		# The player must not be moving
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_TREADING_WATER:
				# Move the collison shape to match the player
				player.collision_shape.rotation_degrees.x = 0
				# Play the "treading water" animation
				player.animation_player.play(ANIMATION_TREADING_WATER)


## Start "swimming".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.SWIMMING
	# Flag the player as "swimming"
	player.is_swimming = true
	# Set the player's speed
	player.speed_current = player.speed_swimming
	# Set player properties
	player.gravity = 0.0
	player.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	# Place player just below water surface and preserve downward velocity for splash
	if player.is_swimming_in:
		var parent_position = player.is_swimming_in.get_parent().position
		var child_size = player.is_swimming_in.get_child(0).shape.size
		var water_top = parent_position.y + (child_size.y / 2)
		var player_half_height = player.collision_height * .75
		# Target position for smooth entry
		swimming_entry_target_y = water_top - player_half_height - 0.05
		swimming_entry_lerp_time = SWIMMING_ENTRY_LERP_DURATION
		# If falling, preserve some downward velocity for splash effect
		if player.velocity.y < 0.0:
			player.velocity.y = min(player.velocity.y, -0.5)
		else:
			player.velocity.y = 0.0
	else:
		swimming_entry_target_y = player.position.y + 0.1
		swimming_entry_lerp_time = SWIMMING_ENTRY_LERP_DURATION
		player.velocity.y = 0.0


## Stop "swimming".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "swimming"
	player.is_swimming = false
	# [Re]Set player properties
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	player.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	player.velocity.y -= player.gravity
	player.visuals.rotation.x = 0
	player.visuals_aux_scene.position.y = 0.0
	# Remove which body the player is swimming in
	player.is_swimming_in = null
	# Reset the collison shape to match the player
	player.collision_shape.rotation_degrees.x = 0
