extends BaseState

const ANIMATION_CLIMBING_IN_PLACE = "Climbing_Up_Wall_In_Place" + "/mixamo_com"
const ANIMATION_HANGING_SHIMMY_LEFT := "Braced_Hang_Shimmy_Left_In_Place" + "/mixamo_com"
const ANIMATION_HANGING_SHIMMY_RIGHT := "Braced_Hang_Shimmy_Right_In_Place" + "/mixamo_com"
const NODE_NAME := "Climbing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓨ/[Ctrl] _pressed_ -> Start "falling"
		if event.is_action_pressed("button_3"):
			# Start falling
			transition(NODE_NAME, "Falling")
			return

		# Ⓐ/[Space] _pressed_ and jumping is enabled -> Start "jumping"
		if event.is_action_pressed("button_0") and player.enable_jumping:
			# ToDo: Jump up and climb higher
			pass


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	# Check if the player is "climbing"
	if player.is_climbing:
		# Check if the player has no raycast collision
		if !player.raycast_high.is_colliding():
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

	var move_direction = Vector3.ZERO

	# Check current input states to support diagonal movement
	if Input.is_action_pressed("move_left"):
		move_direction += wall_right * -1
	if Input.is_action_pressed("move_right"):
		move_direction += wall_right
	if Input.is_action_pressed("move_up"):
		move_direction += Vector3.UP
	if Input.is_action_pressed("move_down"):
		move_direction += Vector3.UP * -1

	# Normalize for consistent speed when moving diagonally
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()

	# Scale the speed based on the player's size
	var speed_current_scaled = player.speed_current * player.scale.x

	# Apply movement
	player.velocity = move_direction * speed_current_scaled
	player.move_and_slide()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	if !player.is_animation_locked:
		# Check if the player is shimmying
		player.is_shimmying = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")

		# If not moving, just pause current animation
		if player.velocity == Vector3.ZERO:
			player.animation_player.pause()
			return
		
		# Set animation playback speed according to player movement speed
		if player.speed_current == player.speed_crawling:
			player.animation_player.speed_scale = 2.25
		else:
			player.animation_player.speed_scale = 1.5

		if Input.is_action_pressed("move_left"):
			player.visuals_aux_scene.position.y = -1.0 # Adjust visuals for left shimmy
			if player.animation_player.current_animation != ANIMATION_HANGING_SHIMMY_LEFT:
				player.animation_player.play(ANIMATION_HANGING_SHIMMY_LEFT)
			else:
				player.animation_player.play()
			return

		if Input.is_action_pressed("move_right"):
			player.visuals_aux_scene.position.y = -1.0 # Adjust visuals for right shimmy
			if player.animation_player.current_animation != ANIMATION_HANGING_SHIMMY_RIGHT:
				player.animation_player.play(ANIMATION_HANGING_SHIMMY_RIGHT)
			else:
				player.animation_player.play()
			return

		if Input.is_action_pressed("move_up"):
			player.visuals_aux_scene.position.y = -0.4 # Adjust visuals for climbing up
			if player.animation_player.current_animation != ANIMATION_CLIMBING_IN_PLACE:
				player.animation_player.play(ANIMATION_CLIMBING_IN_PLACE)
			else:
				player.animation_player.play()
			return

		if Input.is_action_pressed("move_down"):
			player.visuals_aux_scene.position.y = -0.4 # Adjust visuals for climbing down
			if player.animation_player.current_animation != ANIMATION_CLIMBING_IN_PLACE:
				player.animation_player.play_backwards(ANIMATION_CLIMBING_IN_PLACE)
			else:
				player.animation_player.play_backwards()
			return


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
	player.visuals_aux_scene.position.y = -0.4
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
	player.animation_player.speed_scale = 1.0
	player.animation_player.playback_default_blend_time = 0.2
	player.visuals_aux_scene.position.y = 0.0
