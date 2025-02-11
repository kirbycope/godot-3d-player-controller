extends CharacterBody3D

var player: CharacterBody3D
var follow_distance: float = 1.0
var follow_speed: float = 2.25


func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if the body is a Player
	if body.is_in_group("Player"):
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	# Check if the body is a Player
	if body.is_in_group("Player"):
		player = null
		velocity = Vector3.ZERO


func _process(delta: float) -> void:

	# Check if the player is not null
	if player:

		# Look at player
		look_at(player.global_position)

		# Calculate direction to player
		var direction = player.global_position - global_position
		var distance = direction.length()

		# Only move if we're further than follow_distance
		if distance > follow_distance:
			# Normalize direction and adjust speed
			direction = direction.normalized()
			velocity = direction * follow_speed
		else:
			# Stop moving when at correct distance
			velocity = Vector3.ZERO

		# Apply movement
		move_and_slide()
