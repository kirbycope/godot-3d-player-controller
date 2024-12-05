extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# Check if the player is "hanging"
		if player.is_hanging:

			# [crouch] button currently _pressed_
			if event.is_action_pressed("crouch"):

				# Stop the player "hanging"
				stop_hanging()

			# [jump] button just _pressed_
			if event.is_action_pressed("jump"):

				# Stop the player "hanging"
				stop_hanging()

				# Flag the player as "climbing" (also called "mantling")
				player.is_climbing = true

				# Find the target position
				var collision_point = player.raycast_jumptarget.get_collision_point()

				# Move the player
				var tween = player.get_tree().create_tween()
				tween.tween_property(player, "position", collision_point, 0.2)

				# Delay execution
				await get_tree().create_timer(0.2).timeout

				# Flag the player as no longer "climbing"
				player.is_climbing = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is not on the ground, is not flying, and is not already climbing
	if !player.is_on_floor() and !player.is_flying and !player.is_climbing:

		# Check the eyeline for a ledge to grab.
		if !player.raycast_top.is_colliding() and player.raycast_high.is_colliding():

			# Start the player "hanging"
			start_hanging()

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

			# Flag the player as not jumping
			player.is_jumping = false

			# Reset velocity to prevent any movement
			player.velocity = Vector3.ZERO

			# Delay execution
			await get_tree().create_timer(0.2).timeout

			# Flag the animation player no longer locked
			player.is_animation_locked = false

	# Check if the player is "hanging"
	if player.is_hanging:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != player.animation_hanging:

			# Play the "hanging" animation
			player.animation_player.play(player.animation_hanging)


## Called when the player starts "hanging".
func start_hanging() -> void:

	# Flag the player as "hanging"
	player.is_hanging = true

	# Set the player's movement speed
	player.speed_current = player.speed_crawling

	# Set CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2

	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position


## Called when the player stops "hanging".
func stop_hanging() -> void:

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
