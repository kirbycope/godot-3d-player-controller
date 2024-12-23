extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [crouch] button _pressed_
		if event.is_action_pressed("crouch"):

			# Start falling
			to_falling()

		# [jump] button _pressed_
		if event.is_action_pressed("jump"):

			# Start climbing
			to_climbing()

		# [move_left] button pressed
		if event.is_action_pressed("move_left"):

			# Move the player left
			move_character(-1)

		# [move_right] button pressed
		if event.is_action_pressed("move_right"):

			# Move the player right
			move_character(1)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

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
			if player.animation_player.current_animation != player.animation_hanging_shimmy_left:

				# Play the "hanging, shimmy-ing left" animation
				player.animation_player.play(player.animation_hanging_shimmy_left)

		# Check if the player if moving right
		elif Input.is_action_pressed("move_right"):

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_hanging_shimmy_right:

				# Play the "hanging, shimmy-ing left" animation
				player.animation_player.play(player.animation_hanging_shimmy_right)

		else:

			# Stop player movement
			player.velocity = Vector3.ZERO

			# Re[set] player visuals for animation
			player.visuals_aux_scene.position = player.visuals_aux_scene_position

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_hanging:

				# Play the "hanging" animation
				player.animation_player.play(player.animation_hanging)


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
	States.current_state = States.State.HANGING

	# Flag the player as "hanging"
	player.is_hanging = true

	# Set the player's movement speed
	player.speed_current = player.speed_crawling

	## -- Begin move player into position -- ##
	
	# Get the player's height
	var player_height = player.get_node("CollisionShape3D").shape.height

	# Get the player's width
	var player_width = player.get_node("CollisionShape3D").shape.radius * 4

	# Get the collision point
	var point = player.raycast_high.get_collision_point()

	# Calculate the direction from the player to collision point
	var direction = (point - player.position).normalized()

	# Calculate new point by moving back from point along the direction by the given player radius
	point = point - direction * player_width

	# Adjust the point relative to the player's height
	point.y -= player_height * 0.875

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
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2

	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position


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


## State.HANGING -> State.CLIMBING
func to_climbing() -> void:

	# Stop "hanging"
	stop()

	# Start "climbing"
	$"../Climbing".start()


## State.HANGING -> State.FALLING
func to_falling() -> void:

	# Stop "hanging"
	stop()

	# Start "falling"
	$"../Falling".start()
