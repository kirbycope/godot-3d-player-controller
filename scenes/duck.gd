extends CharacterBody3D

var player: CharacterBody3D
var follow_distance: float = 1.0
var follow_speed: float = 2.25
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var is_following: bool = false
var last_vehicle_hit_time: float = 0.0  # Cooldown to prevent multiple rapid hits
const quack_1 = preload("res://assets/duck/quack_1.wav")
const quack_2 = preload("res://assets/duck/quack_2.wav")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	# Scale audio volume with node size
	audio_player.volume_db *= scale.x


func _on_area_3d_body_entered(body: Node3D) -> void:

	# Check if the body is a Player
	if body.is_in_group("Player"):
		player = body
		audio_player.stream = quack_2
		audio_player.play()


func _on_area_3d_body_exited(body: Node3D) -> void:

	# Check if the body is a Player
	if body.is_in_group("Player"):
		player = null
		is_following = false
		audio_player.stream = quack_1
		audio_player.play()


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
			is_following = true
			# Normalize direction and adjust speed
			direction = direction.normalized()
			velocity.x = direction.x * follow_speed
			velocity.z = direction.z * follow_speed
		else:
			is_following = false
			# Stop moving when at correct distance
			velocity.x = 0
			velocity.z = 0
	else:
		is_following = false
		# Act like RigidBody3D when not following - apply damping
		velocity.x = velocity.x * (1.0 - delta)
		velocity.z = velocity.z * (1.0 - delta)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Apply movement
	move_and_slide()
	
	# Handle being pushed by other objects when not following
	if not is_following:
		handle_collisions()
	
	play_animation()


# Handle collisions and being pushed around
func handle_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider:
			var push_force = Vector3.ZERO

			# If collided with a vehicle (like the Honda CRV), get pushed much harder
			if collider is VehicleBody3D:
				# Cooldown to prevent multiple rapid hits
				var time_since_last_hit = Time.get_ticks_msec() / 1000.0 - last_vehicle_hit_time
				
				if time_since_last_hit > 1.0:  # Only allow hit every 1 second
					var vehicle = collider as VehicleBody3D
					var vehicle_velocity = vehicle.linear_velocity
					var impact_speed = vehicle_velocity.length()
					
					# Use the vehicle's actual movement direction instead of collision normal
					var vehicle_direction = vehicle_velocity.normalized()
					push_force = vehicle_direction * impact_speed * 0.5
					# Add some upward force for dramatic effect
					push_force.y += impact_speed * 0.5
					
					last_vehicle_hit_time = Time.get_ticks_msec() / 1000.0

			# Apply the calculated push force
			if push_force.length() > 0:
				velocity.x += push_force.x
				velocity.z += push_force.z
				velocity.y += push_force.y
				# Play quack sound when hit hard
				if push_force.length() > 5.0:
					audio_player.stream = quack_1
					audio_player.play()


# Function to apply external forces (like being pushed by player or other objects)
func apply_external_force(force: Vector3) -> void:
	if not is_following:
		velocity += force


func play_animation() -> void:
	if velocity.x != 0.0 or velocity.z != 0.0:
		if animation_player.current_animation != "Walk":
			animation_player.play("Walk")
	else:
		animation_player.play("Armature|White Duck_TempMotion|White Duck_TempMotion")
