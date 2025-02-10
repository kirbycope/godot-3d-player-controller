extends BaseState

const animation_hanging = "Hanging_Idle"
const animation_hanging_shimmy_left = "Braced_Hang_Shimmy_Left_In_Place"
const animation_hanging_shimmy_right = "Braced_Hang_Shimmy_Right_In_Place"
var node_name = "Hanging"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [crouch] button _pressed_
		if event.is_action_pressed("crouch"):

			# Start falling
			transition(node_name, "Falling")

		# [jump] button _pressed_
		if event.is_action_pressed("jump"):

			# Start climbing
			transition(node_name, "Climbing")

		# [move_left] button pressed
		if event.is_action_pressed("move_left"):

			# Move the player left
			move_character(-1)

		# [move_right] button pressed
		if event.is_action_pressed("move_right"):

			# Move the player right
			move_character(1)


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is "hanging"
	if player.is_hanging:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is moving left
		if Input.is_action_pressed("move_left"):

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_hanging_shimmy_left:

				# Stop the current animation so no blending occurs
				player.animation_player.stop()

				# Play the "hanging, shimmy-ing left" animation
				player.animation_player.play(animation_hanging_shimmy_left)

		# Check if the player if moving right
		elif Input.is_action_pressed("move_right"):

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_hanging_shimmy_right:

				# Stop the current animation so no blending occurs
				player.animation_player.stop()

				# Play the "hanging, shimmy-ing left" animation
				player.animation_player.play(animation_hanging_shimmy_right)

		# The player must not be moving
		else:

			# Stop player movement
			player.velocity = Vector3.ZERO

			# Re[set] player visuals for animation
			player.visuals_aux_scene.position = player.visuals_aux_scene_position

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != animation_hanging:

				# Stop the current animation so no blending occurs
				player.animation_player.stop()

				# Play the "hanging" animation
				player.animation_player.play(animation_hanging)


## Moves the player in the given direction.
func move_character(direction: float) -> void:

	# Adjust player visuals for animation
	player.visuals_aux_scene.position.y -= 0.45

	# Calculate movement vector based on camera's orientation
	var move_direction = player.camera.global_transform.basis * Vector3(direction, 0, 0)

	# Apply movement
	player.velocity = move_direction * player.speed_current

	# If using CharacterBody3D, you need to call move_and_slide()
	player.move_and_slide()


## Start "hanging".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.HANGING

	# Flag the player as "hanging"
	player.is_hanging = true

	# Set the player's movement speed
	player.speed_current = player.speed_crawling

	## -- Begin move player into position -- ##
	
	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height

	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 2

	# Get the collision point
	var point = player.raycast_high.get_collision_point()

	# Calculate the direction from the player to collision point
	var direction = (point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	point = point - direction * player_width

	# Adjust the point relative to the player's height
	point.y -= player_height * 0.875

	# Get the collision normal
	var normal = player.raycast_high.get_collision_normal()

	# Calculate the rotation to align with the wall
	# The player should face the wall
	var target_basis = Basis()
	target_basis.y = Vector3.UP  # Keep upright
	target_basis.z = normal     # Face the wall
	target_basis.x = target_basis.y.cross(target_basis.z)  # Calculate right vector
	target_basis = target_basis.orthonormalized()  # Ensure basis is orthonormal

	# Set the player's rotation
	player.basis = target_basis

	# Set the player's position to the new point
	player.position = point

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Reset velocity to prevent any movement
	player.velocity = Vector3.ZERO

	# Delay execution
	await get_tree().create_timer(0.2).timeout

	# Flag the animation player no longer locked
	player.is_animation_locked = false

	## -- End move player into position -- ##

	# Set CollisionShape3D height
	#player.get_node("CollisionShape3D").shape.height = player.collision_height / 2

	# Set CollisionShape3D position
	#player.get_node("CollisionShape3D").position = player.collision_position


## Stop "hanging".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag player as not "hanging"
	player.is_hanging = false

	# [Re]Set the player's movement speed
	player.speed_current = player.speed_walking

	# Make the player start falling again
	player.velocity.y = -player.gravity

	# Reset CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height

	# Reset CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position
