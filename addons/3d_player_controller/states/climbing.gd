extends BaseState
## climbinig.gd

# States (states.gd)
#├── Base (base.gd)
#├── Climbing (climbing.gd)
#├── Crawling (crawling.gd)
#├── Crouching (crouching.gd)
#├── Driving (driving.gd)
#├── Falling (falling.gd)
#├── Flying (flying.gd)
#├── Hanging (hanging.gd)
#├── Holding (holding.gd)
#├── Jumping (jumping.gd)
#├── Running (running.gd)
#├── Skateboarding (skateboarding.gd)
#├── Sprinting (sprinting.gd)
#├── Standing (standing.gd)
#├── Swimming (swimming.gd)
#└── Walking (walking.gd)

const ANIMATION_CLIMBING_IN_PLACE = "Climbing_Up_Wall_In_Place" + "/mixamo_com"
const ANIMATION_HANGING_SHIMMY_LEFT := "Braced_Hang_Shimmy_Left_In_Place" + "/mixamo_com"
const ANIMATION_HANGING_SHIMMY_RIGHT := "Braced_Hang_Shimmy_Right_In_Place" + "/mixamo_com"
const NODE_NAME := "Climbing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# [crouch] button _pressed_
		if event.is_action_pressed("crouch"):
			# Start falling
			transition(NODE_NAME, "Falling")
			return

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:
			# ToDo: Jump up and climb higher
			pass

		# [sprint] button just _pressed_
		if event.is_action_pressed("sprint"):
			# ToDo: Climb faster
			pass


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Check the eyeline for a ledge to grab.
		if !player.raycast_top.is_colliding() and player.raycast_high.is_colliding():
			# Get the collision object
			var collision_object = player.raycast_high.get_collider()

			# Only proceed if the collision object is not in the "held" group and not a player
			if !collision_object.is_in_group("held") and !collision_object is CharacterBody3D:
				# Start "hanging"
				transition(NODE_NAME, "Hanging")
				return

		# Check if the player is on the ground (and has no vertical velocity)
		if player.is_on_floor() and player.velocity.y == 0.0:
			# Start "standing"
			transition(NODE_NAME, "Standing")
			return

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

	# Apply movement
	player.velocity = move_direction * player.speed_current
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
	#_draw_debug_sphere(collision_point, Color.RED)

	# Get the collision normal
	var collision_normal = player.raycast_high.get_collision_normal()
	var wall_direction = - collision_normal
	
	# Ensure the wall direction is horizontal (remove any vertical component)
	wall_direction.y = 0.0
	wall_direction = wall_direction.normalized()
	
	# Make the player face the wall while keeping upright
	player.look_at(player.position + wall_direction, Vector3.UP)

	# Calculate the direction from the player to collision point
	var direction = (collision_point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * player_width

	# [DEBUG] Draw a debug sphere at the collision point
	#_draw_debug_sphere(collision_point, Color.YELLOW)

	# Adjust the point relative to the player's height
	collision_point = Vector3(collision_point.x, player.position.y, collision_point.z)

	# Move center of player to the collision point
	player.position = collision_point

	# [Hack] Adjust player visuals for animation
	player.visuals_aux_scene.position.y = -0.4
	player.animation_player.play(ANIMATION_CLIMBING_IN_PLACE)
	player.animation_player.playback_default_blend_time = 0.0

	# [DEBUG] Draw a debug sphere at the collision point
	#_draw_debug_sphere(collision_point, Color.GREEN)

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Reset velocity to prevent any movement
	player.velocity = Vector3.ZERO

	# Delay execution
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
	player.animation_player.playback_default_blend_time = 0.2
	player.visuals_aux_scene.position.y = 0.0


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
