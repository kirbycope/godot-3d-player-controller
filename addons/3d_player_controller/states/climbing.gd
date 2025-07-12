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
const NODE_NAME := "Climbing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# [crouch] button _pressed_
		if event.is_action_pressed("crouch"):
			# Start falling
			transition(NODE_NAME, "Falling")

		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:
			# ToDo: Mantle up
			pass

		# [move_down] button pressed
		if event.is_action_pressed("move_down"):
			# Move the player down
			move_character(-1)

		# [move_down] button released
		if event.is_action_released("move_down"):
			# Stop moving down
			move_character(0)
			pass

		# [move_up] button pressed
		if event.is_action_pressed("move_up"):
			# Move the player up
			move_character(1)

		# [move_up] button released
		if event.is_action_released("move_up"):
			# Stop moving up
			move_character(0)

		# [sprint] button just _pressed_
		if event.is_action_pressed("sprint"):
			# ToDo: Drop down
			pass


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
			transition(NODE_NAME, "Hanging")

	# Check if the player is "climbing"
	if player.is_climbing:
		# Play the animation
		play_animation()


## Moves the player in the given direction.
func move_character(direction: float) -> void:
	# Get the wall normal from the raycast
	var wall_normal = player.raycast_high.get_collision_normal()

	# Move along the up vector instead of wall_right
	var move_direction = Vector3.UP * direction

	# Apply movement
	player.velocity = move_direction * player.speed_current

	# If using CharacterBody3D, you need to call move_and_slide()
	player.move_and_slide()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the player is not moving
		if player.velocity == Vector3.ZERO:
			# Pause the animation player
			player.animation_player.pause()
		# The player must be moving
		else:
			# Resume the animation player
			player.animation_player.play()

		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_CLIMBING_IN_PLACE:
			# Play the "climbing" animation
			player.animation_player.play(ANIMATION_CLIMBING_IN_PLACE)


## Start "climbing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = STATES.State.CLIMBING

	# Flag the player as "climbing"
	player.is_climbing = true

	# Set the player's movement speed
	player.speed_current = player.speed_crawling

	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height

	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 2

	# Get the collision point
	var collision_point = player.raycast_high.get_collision_point()

	# Calculate the direction from the player to collision point
	var direction = (collision_point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	collision_point = collision_point - direction * player_width

	# Adjust the point relative to the player's height
	collision_point.y -= player_height * 0.875

	# Get the collision normal
	var normal = player.raycast_high.get_collision_normal()

	# Get the current player's forward direction
	var current_forward = - player.transform.basis.z.normalized()

	# Check if player is already facing the wall correctly
	# If the dot product is close to 1, they're already facing the wall
	var dot_product = current_forward.dot(normal)

	# If player is already facing the wall well enough, don't change rotation
	var target_rotation
	if dot_product > 0.7: # Threshold for "close enough"
		target_rotation = player.rotation
	else:
		# Calculate the rotation to align with the wall
		# The player should face the wall (same direction as normal)
		var forward = normal
		var up = Vector3.UP
		var right = up.cross(forward).normalized()

		# Handle case where forward and up are parallel (shouldn't happen on walls)
		if right.length_squared() < 0.001:
			right = Vector3.RIGHT

		# Create the target basis
		var target_basis = Basis(right, up, forward)

		# Ensure the basis is orthonormal
		target_basis = target_basis.orthonormalized()

		# Get rotation from the target basis
		target_rotation = target_basis.get_euler()

		# Get the current player rotation
		var current_y_rotation = player.rotation.y

		# Find the equivalent target rotation that's closest to current rotation
		var target_y_rotation = target_rotation.y

		var angle_options = [
			target_y_rotation,
			target_y_rotation + 2 * PI,
			target_y_rotation - 2 * PI
		]

		# Choose the angle closest to current rotation
		var best_angle = target_y_rotation
		var min_diff = abs(current_y_rotation - target_y_rotation)

		for angle in angle_options:
			var diff = abs(current_y_rotation - angle)
			if diff < min_diff:
				min_diff = diff
				best_angle = angle

		# Use the best angle
		target_rotation.y = best_angle

	# Set the player's rotation
	player.rotation = target_rotation

	# Set the player's position to the new point
	player.position = collision_point

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
