extends BaseState

const ANIMATION_HANGING := "Hanging_Idle" + "/mixamo_com"
const ANIMATION_HANGING_SHIMMY_LEFT := "Braced_Hang_Shimmy_Left_In_Place" + "/mixamo_com"
const ANIMATION_HANGING_SHIMMY_RIGHT := "Braced_Hang_Shimmy_Right_In_Place" + "/mixamo_com"
const NODE_NAME := "Hanging"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# [crouch] button _pressed_
		if event.is_action_pressed("button_3"):
			# Start falling
			transition(NODE_NAME, "Falling")
			return

		# [jump] button _pressed_
		if event.is_action_pressed("button_0"):
			# Check if there is a raycast collision
			if player.raycast_jumptarget.is_colliding():
				# Get the collision point
				var collision_point = player.raycast_jumptarget.get_collision_point()
				
				# Temporarily disable player collision to avoid physics interference during mantle
				player.collision_shape.disabled = true
				
				# Reset velocity to prevent unwanted movement
				player.velocity = Vector3.ZERO
				player.virtual_velocity = Vector3.ZERO
				
				# Set the player's position to the collision point
				var tween = get_tree().create_tween()
				tween.tween_property(player, "position", collision_point, 0.2)
				
				# Wait for the tween to complete
				await tween.finished
				
				# Wait an additional frame for physics to settle
				await get_tree().physics_frame
				
				# Re-enable collision after positioning is complete
				player.collision_shape.disabled = false
				
				# Check if the player is in first-person perspective
				if player.perspective == 1:
					# Rotate the body to match the camera_mount
					player.visuals.rotation = Vector3(0.0, player.camera_mount.rotation.y, player.camera_mount.rotation.z)
				# Start "standing"
				transition(NODE_NAME, "Standing")
				return


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	# Check if the player is "hanging"
	if player.is_hanging:
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

	# Move the player in the current direction
	move_character()

	# Check if the player is "hanging"
	if player.is_hanging:
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

	# Normalize for consistent speed when moving diagonally
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()

	# Apply movement
	player.velocity = move_direction * player.speed_current
	player.move_and_slide()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the player is shimmying
		player.is_shimmying = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")

		# If not moving, just pause current animation
		if player.velocity == Vector3.ZERO:
			player.visuals_aux_scene.position.y = -0.55 # Adjust visuals for hanging
			if player.animation_player.current_animation != ANIMATION_HANGING:
				player.animation_player.play(ANIMATION_HANGING)
			else:
				player.animation_player.play()
			return

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


## Start "hanging".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = STATES.State.HANGING

	# Flag the player as "hanging"
	player.is_hanging = true

	# Set the player's movement speed
	player.speed_current = player.speed_climbing

	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height

	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 2

	# Get the collision point
	var collision_point = player.raycast_high.get_collision_point()

	# [DEBUG] Draw a debug sphere at the collision point
	#_draw_debug_sphere(collision_point, Color.RED)

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
	#_draw_debug_sphere(collision_point, Color.YELLOW)

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, player.position.y, collision_point.z)

	# Reset velocity and virtual velocity before setting position to prevent input interference
	player.velocity = Vector3.ZERO
	player.virtual_velocity = Vector3.ZERO

	# Move center of player to the collision point
	player.global_position = collision_point

	# [DEBUG] Draw a debug sphere at the collision point
	#_draw_debug_sphere(collision_point, Color.GREEN)

	# Wait one frame to ensure position is set before continuing
	await get_tree().process_frame

	# Make the player face the wall while keeping upright
	player.visuals.look_at(player.position + wall_direction, Vector3.UP)

	# [Hack] Adjust player visuals for animation
	player.animation_player.playback_default_blend_time = 0.0

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Delay execution to ensure position is properly set and no input interference
	await get_tree().create_timer(0.2).timeout

	# Flag the animation player no longer locked
	player.is_animation_locked = false


## Stop "hanging".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag player as not "hanging"
	player.is_hanging = false

	# Flag the player as not "shimmying"
	player.is_shimmying = false

	# Make the player start falling again
	player.velocity.y = - player.gravity

	# [Hack] Reset player visuals for animation
	player.visuals_aux_scene.position.y = 0.0
	player.animation_player.playback_default_blend_time = 0.2


## Draws a debug sphere at the given position.
func _draw_debug_sphere(pos: Vector3, color: Color) -> void:
	var debug_sphere = MeshInstance3D.new()
	player.get_tree().get_root().add_child(debug_sphere)
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	debug_sphere.mesh = sphere_mesh
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	debug_sphere.material_override = material
	debug_sphere.global_position = pos
