extends BaseState

const ANIMATION_CLIMBING_IN_PLACE = "Climbing_Up_Wall_In_Place" + "/mixamo_com"
const ANIMATION_BRACED_HANG_SHIMMY_LEFT := "Braced_Hang_Shimmy_Left_In_Place" + "/mixamo_com"
const ANIMATION_BRACED_HANG_SHIMMY_RIGHT := "Braced_Hang_Shimmy_Right_In_Place" + "/mixamo_com"
const NODE_NAME := "Climbing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
		if event.is_action_pressed("button_3"):
			# Start falling
			transition(NODE_NAME, "Falling")
			return
		# Ⓐ/[Space] _pressed_ and jumping is enabled -> Start "jumping"
		if event.is_action_pressed("button_0") and player.enable_jumping and !player.is_animation_locked:
			# ToDo: Jump up and climb higher
			pass


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is "climbing"
	if player.is_climbing:
		# Check if the player has no raycast collision
		if !player.raycast_top.is_colliding() and !player.raycast_high.is_colliding():
			# Start falling
			transition(NODE_NAME, "Falling")
			return
	# Check if the player is on the ground (and has no vertical velocity)
	if player.is_on_floor() and player.velocity.y == 0.0:
		# Start "standing"
		transition(NODE_NAME, "Standing")
		return
	# Check the eyeline for a ledge to grab.
	if !player.raycast_top.is_colliding() and player.raycast_high.is_colliding():
		# Get the collision object
		var collision_object = player.raycast_high.get_collider()

		# Only proceed if the collision object is not in the "held" group and not a player
		if !collision_object.is_in_group("held") and !collision_object is CharacterBody3D:
			# Start "hanging"
			transition(NODE_NAME, "Hanging")
			return
	# [sprint] button _pressed_
	if Input.is_action_pressed("button_1"):
		# Make the player climb faster
		player.speed_current = player.speed_crawling
	# [sprint] button just _released_
	if Input.is_action_just_released("button_1"):
		# Make the player climb normal speed
		player.speed_current = player.speed_climbing
	# Move the player in the current direction
	move_character()
	# Check if the player is "climbing"
	if player.is_climbing:
		# Play the animation
		play_animation()


## Moves the player in the current direction.
func move_character() -> void:
	# Get the wall normal from the raycast
	var wall_normal = player.raycast_high.get_collision_normal()
	# Calculate the right vector (perpendicular to wall normal and up)
	var wall_right = Vector3.UP.cross(wall_normal).normalized()
	# Initialize movement direction
	var move_direction = Vector3.ZERO
	# Check current input states to support diagonal movement
	if Input.is_action_pressed("move_left"):
		move_direction -= wall_right
	if Input.is_action_pressed("move_right"):
		move_direction += wall_right
	if Input.is_action_pressed("move_up"):
		move_direction += Vector3.UP
	if Input.is_action_pressed("move_down"):
		move_direction -= Vector3.UP
	# Normalize for consistent speed when moving diagonally
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
	# Scale the speed based on the player's size
	var speed_current_scaled = player.speed_current * player.scale.x
	# Calculate wall direction (opposite of the collision normal, horizontal only)
	var wall_direction = -wall_normal
	wall_direction.y = 0.0
	wall_direction = wall_direction.normalized()
	# Move player to the wall if needed
	var collision_point = player.raycast_high.get_collision_point()
	var distance = player.raycast_high.global_position.distance_to(collision_point)
	if distance > player.collision_radius + 0.2:
		# Move the player to 0.2 away from the wall
		player.position += wall_direction * (distance - (player.collision_radius + 0.2))
	# Make the player face the wall while keeping upright
	var forward = -wall_normal
	var right = Vector3.UP.cross(forward).normalized()
	var adjusted_up = forward.cross(right).normalized()
	player.visuals.look_at(player.position + forward, adjusted_up)
	# Apply movement
	player.velocity = move_direction * speed_current_scaled
	player.move_and_slide()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if !player.is_animation_locked:
		# Check if the player's hang is braced (the collider has somewhere for the player's footing)
		player.is_braced = player.raycast_low.is_colliding()
		# Check if the player is shimmying
		player.is_shimmying = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
		# Check if the player is not moving -> Pause current animation
		if player.velocity == Vector3.ZERO:
			# Pause the animation player
			player.animation_player.pause()
			# Stop processing animations
			return
		# Check if the player's current speed -> Adjust animation speed
		if player.speed_current == player.speed_crawling:
			# The player is "sprinting" while climbing
			player.animation_player.speed_scale = 2.25
		else:
			# The player is climbing "normally"
			player.animation_player.speed_scale = 1.5
		# Check if the player is moving left -> Play "shimmy left" animation
		if Input.is_action_pressed("move_left"):
			# Check if playing the "braced hang, shimmy left" animation
			if player.animation_player.current_animation != ANIMATION_BRACED_HANG_SHIMMY_LEFT:
				# [Hack] Adjust visuals for shimmying
				player.player_skeleton.position.x = 0.0
				player.player_skeleton.position.y = -1.0
				player.player_skeleton.position.z = 0.0
				# Play the "braced hang, shimmy left" animation
				player.animation_player.play(ANIMATION_BRACED_HANG_SHIMMY_LEFT)
			else:
				player.animation_player.play()
			# Return early so that up/down animations are skipped
			return
		# Check if the player is moving right -> Play "shimmy right" animation
		if Input.is_action_pressed("move_right"):
			# Check if playing the "braced hang, shimmy right" animation
			if player.animation_player.current_animation != ANIMATION_BRACED_HANG_SHIMMY_RIGHT:
				# [Hack] Adjust visuals for shimmying
				player.player_skeleton.position.x = 0.0
				player.player_skeleton.position.y = -1.0
				player.player_skeleton.position.z = 0.0
				# Play the "braced hang, shimmy right" animation
				player.animation_player.play(ANIMATION_BRACED_HANG_SHIMMY_RIGHT)
			else:
				player.animation_player.play()
			# Return early so that up/down animations are skipped
			return
		# Check if the player is moving up -> Play "climbing up" animation
		if Input.is_action_pressed("move_up"):
			# Check if playing the "climbing" animation
			if player.animation_player.current_animation != ANIMATION_CLIMBING_IN_PLACE:
				# [Hack] Adjust visuals for climbing
				player.player_skeleton.position.x = 0.0
				player.player_skeleton.position.y = -0.4
				player.player_skeleton.position.z = 0.0
				# Play the "climbing" animation
				player.animation_player.play(ANIMATION_CLIMBING_IN_PLACE)
			else:
				player.animation_player.play()
		# Check if the player is moving down -> Play "climbing down" animation
		if Input.is_action_pressed("move_down"):
			# Check if playing the "climbing" animation
			if player.animation_player.current_animation != ANIMATION_CLIMBING_IN_PLACE:
				# [Hack] Adjust visuals for climbing
				player.player_skeleton.position.x = 0.0
				player.player_skeleton.position.y = -0.4 
				player.player_skeleton.position.z = 0.0
				# Play the "climbing" animation (backwards)
				player.animation_player.play_backwards(ANIMATION_CLIMBING_IN_PLACE)
			else:
				player.animation_player.play_backwards()


## Start "climbing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.CLIMBING
	# Flag the player as "climbing"
	player.is_climbing = true
	# Set the player's movement speed
	player.speed_current = player.speed_climbing
	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height
	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 2
	# Get the collision point
	var collision_point = player.raycast_high.get_collision_point()
	# [DEBUG] Draw a debug sphere at the collision point
	#draw_debug_sphere(collision_point, Color.RED)
	# Get the collision normal
	var collision_normal = player.raycast_high.get_collision_normal()
	var wall_direction = - collision_normal
	# Ensure the wall direction is horizontal (remove any vertical component)
	wall_direction.y = 0.0
	wall_direction = wall_direction.normalized()
	# Calculate the direction from the player to collision point
	var direction = (collision_point - player.position).normalized()
	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * player_width
	# [DEBUG] Draw a debug sphere at the collision point
	#draw_debug_sphere(collision_point, Color.YELLOW)
	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, player.position.y, collision_point.z)
	# Reset velocity and virtual velocity before setting position to prevent input interference
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO
	# Move center of player to the collision point
	player.global_position = collision_point
	# [DEBUG] Draw a debug sphere at the collision point
	#draw_debug_sphere(collision_point, Color.GREEN)
	# Wait one frame to ensure position is set before continuing
	await get_tree().process_frame
	# Make the player face the wall while keeping upright
	if player.position != player.position + wall_direction:
		player.visuals.look_at(player.position + wall_direction, Vector3.UP)
	# [Hack] Adjust player visuals for animation
	player.player_skeleton.position.y = -0.4
	player.animation_player.play(ANIMATION_CLIMBING_IN_PLACE)
	player.animation_player.playback_default_blend_time = 0.0
	# Flag the animation player as locked
	player.is_animation_locked = true
	# Delay execution to ensure position is properly set and no input interference
	await get_tree().create_timer(0.2).timeout
	# Flag the animation player no longer locked
	player.is_animation_locked = false


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "climbing"
	player.is_climbing = false
	# [Hack] Reset player visuals for animation
	player.player_skeleton.position.x = 0.0
	player.player_skeleton.position.y = 0.0
	player.player_skeleton.position.z = 0.0
	player.visuals.rotation = Vector3.ZERO
	player.animation_player.playback_default_blend_time = 0.2
	player.animation_player.speed_scale = 1.0
