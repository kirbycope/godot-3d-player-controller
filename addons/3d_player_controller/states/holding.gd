extends BaseState

const ANIMATION_CROUCHING_AIMING_RIFLE := "Rifle_Aiming_Idle_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_FIRING_RIFLE := "Rifle_Firing_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_HOLDING_RIFLE := "Rifle_Idle_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE := "Rifle_Walk_Crouching" + "/mixamo_com"
const ANIMATION_STANDING_AIMING_RIFLE := "Rifle_Aiming_Idle" + "/mixamo_com"
const ANIMATION_STANDING_FIRING_RIFLE := "Rifle_Firing" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_RIFLE := "Rifle_Low_Idle" + "/mixamo_com"
const ANIMATION_STANDING_CASTING_FISHING_ROD := "Fishing_Cast" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_FISHING_ROD := "Fishing_Idle" + "/mixamo_com"
const ANIMATION_STANDING_REELING_FISHING_ROD := "Fishing_Reel" + "/mixamo_com"
const ANIMATION_STANDING_THROWING_LEFT := "Throw_Object_Left" + "/mixamo_com"
const ANIMATION_STANDING_THROWING_RIGHT := "Throw_Object_Right" + "/mixamo_com"
const NODE_NAME := "Holding"

@export var held_object_rotation_speed: float = 0.2618  # 15 degrees in radians = 15 * (π / 180)

var manual_rotation_x := 0.0 ## Track the manual rotation of the "held" object around the X-axis
var manual_rotation_z := 0.0 ## Track the manual rotation of the "held" object around the Z-axis


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# (L1)/[L-Clk] _pressed_ (and holding something) -> Throw the held object
		if event.is_action_pressed("button_4") and player.is_holding:
			# Throw the held object
			throw_held_object()
			# Stop handling any further input
			return
		# (X)/[E] _pressed_ (and not holding something) -> Pick up the object
		if event.is_action_pressed("button_2") and !player.is_holding:
			# Check if the player is looking at something
			if player.raycast_lookat.is_colliding():
				# Get the object the RayCast is colliding with
				var collider = player.raycast_lookat.get_collider()
				# Check if the collider is a RigidBody3D
				if collider is RigidBody3D and collider is not VehicleBody3D:
					# Flag the RigidBody3D as being "held"
					collider.add_to_group("held")
					# Move the collider to Layer 2
					collider.collision_layer = 2
					# Enable contact monitoring when picking up
					collider.contact_monitor = true
					collider.max_contacts_reported = 1
					# Flag the player as "holding" something
					player.is_holding = true
					# Reset manual rotation when picking up new object
					manual_rotation_x = 0.0
					manual_rotation_z = 0.0
					# Scale the object opposite to the player's scale
					if player.scale.x != 0:
						collider.scale = Vector3(
							1 / player.scale.x,
							1 / player.scale.y,
							1 / player.scale.z
						)
					# Stop handling any further input
					return
		# (X)/[E] _pressed_ (and holding something) -> Drop the held object
		if event.is_action_pressed("button_2") and player.is_holding:
			# Get the nodes in the "held" group
			var held_nodes = get_tree().get_nodes_in_group("held")
			# Check if nodes were found in the group
			if not held_nodes.is_empty():
				# Get the first node in the "held" group
				var held_node = held_nodes[0]
				# Flag the node as no longer "held"
				held_node.remove_from_group("held")
				# Move the collider to Layer 2
				held_node.collision_layer = 1
				# Disable contact monitoring when dropping
				if held_node is RigidBody3D:
					held_node.contact_monitor = false
					held_node.max_contacts_reported = 0
				# Flag the player as not "holding" something
				player.is_holding = false
				# Stop handling any further input
				return


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Set the player as "rotating" if they are holding something and pressing R1
	player.is_rotating_object = player.is_holding and Input.is_action_pressed("button_5")
	# (R1)/[R-Clk] _pressed_ + (D-Up)/[Tab] _just_pressed_ (and holding something) -> rotate the held object upwards
	if Input.is_action_pressed("button_5") and Input.is_action_just_pressed("button_12") and player.is_holding:
		# Increment the manual rotation angle
		manual_rotation_x -= held_object_rotation_speed
	# (R1)/[R-Clk] _pressed_ + (D-Down)/[Q] _just_pressed_ (and holding something) -> rotate the held object downwards
	if Input.is_action_pressed("button_5") and Input.is_action_just_pressed("button_13") and player.is_holding:
		# Increment the manual rotation angle
		manual_rotation_x += held_object_rotation_speed
	# (R1)/[R-Clk] _pressed_ + (D-Left)/[B] _just_pressed_ (and holding something) -> rotate the held object left
	if Input.is_action_pressed("button_5") and Input.is_action_just_pressed("button_14") and player.is_holding:
		# Increment the manual rotation angle
		manual_rotation_z += held_object_rotation_speed
	# (R1)/[R-Clk] _pressed_ + (D-Left)/[T] _just_pressed_ (and holding something) -> rotate the held object right
	if Input.is_action_pressed("button_5") and Input.is_action_just_pressed("button_15") and player.is_holding:
		# Increment the manual rotation angle
		manual_rotation_z -= held_object_rotation_speed
	# Check if the player is holding an object
	if player.is_holding:
		# Move the held object in front of the player
		move_held_object()


## Moves the held object in front of the player.
func move_held_object() -> void:
	# Get the nodes in the "held" group
	var held_nodes = get_tree().get_nodes_in_group("held")
	# Check if nodes were found in the group
	if not held_nodes.is_empty():
		# Get the first node in the "held" group
		var held_node = held_nodes[0]
		# Check if the held node is a RigidBody3D
		if held_node is RigidBody3D:
			# Check if the held node and ray are colliding (seperatly)
			# Note: The held node must have Solver > Contact Monitor > set True and Max Contact to 1 or more
			if held_node.get_colliding_bodies().size() > 0 and player.raycast_lookat.is_colliding():
				# Get the collision point of the ray
				var collision_point = player.raycast_lookat.get_collision_point()
				# Get the (normalized) direction of the ray
				var direction = player.raycast_lookat.global_transform.basis.z.normalized()
				# Access the shape's size from the CollisionShape3D
				var collision_shape_node = held_node.get_node("CollisionShape3D") if held_node.has_node("CollisionShape3D") else held_node.find_child("CollisionShape3D", true)
				if not collision_shape_node:
					return  # Exit if no collision shape found
				var shape = collision_shape_node.shape
				var object_depth = 0.0
				if shape is BoxShape3D:
					object_depth = shape.size.z
				elif shape is SphereShape3D:
					object_depth = shape.radius * 2.0
				elif shape is CapsuleShape3D:
					object_depth = shape.height + shape.radius * 2.0
				else:
					object_depth = 1.0
				# Offset the object backward along the ray direction
				held_node.global_position = collision_point + direction * (object_depth * 0.5)
			# The node must not be colliding
			else:
				# Get the origin position of ray
				var origin = player.raycast_lookat.global_transform.origin
				# Get the (normalized) direction of the ray
				var direction = - player.raycast_lookat.global_transform.basis.z.normalized()
				# Access the shape's size from the CollisionShape3D to calculate radius and height
				var collision_shape_node = held_node.get_node("CollisionShape3D") if held_node.has_node("CollisionShape3D") else held_node.find_child("CollisionShape3D", true)
				if not collision_shape_node:
					return  # Exit if no collision shape found
				var shape = collision_shape_node.shape
				var object_radius = 0.0
				var object_height = 0.0
				if shape is BoxShape3D:
					# For box shapes, use the largest dimension as radius
					var max_size = max(shape.size.x, max(shape.size.y, shape.size.z))
					object_radius = max_size * 0.5
					object_height = shape.size.y
				elif shape is SphereShape3D:
					object_radius = shape.radius
					object_height = shape.radius * 2.0
				elif shape is CapsuleShape3D:
					object_radius = max(shape.radius, shape.height * 0.5)
					object_height = shape.height + shape.radius * 2.0
				else:
					# Shape unknown, default to a 1m sphere
					object_radius = 0.5
					object_height = 1.0
				# Calculate additional distance based on height if object is taller than 1m
				var height_offset = 0.0
				var vertical_offset = 0.0
				if object_height > 1.0:
					height_offset = (object_height/2) - 1.0
					vertical_offset = (object_height/2) - 1.0
				# Set the distance from the player that the object is held
				var distance = 1 + object_radius
				# Move the held object to the new position with vertical offset
				var target_position = origin + (direction * distance)
				target_position.y += vertical_offset
				held_node.global_position = target_position
		# Set rotation: combine manual rotations with player Y rotation
		held_node.rotation.x = manual_rotation_x
		held_node.rotation.y = player.rotation.y
		held_node.rotation.z = player.rotation.z + manual_rotation_z
		# Reset velocities
		held_node.linear_velocity = Vector3.ZERO
		held_node.angular_velocity = Vector3.ZERO


# Add this new function to throw the held object
func throw_held_object() -> void:
	# Get the nodes in the "held" group
	var held_nodes = get_tree().get_nodes_in_group("held")
	# Check if nodes were found in the group
	if not held_nodes.is_empty():
		# Get the first node in the "held" group
		var held_node = held_nodes[0]
		# Flag the node as no longer "held"
		held_node.remove_from_group("held")
		# Move the collider back to Layer 1
		held_node.collision_layer = 1
		# Flag the player as no longer "holding" something
		player.is_holding = false
		# Get the direction the player is looking
		var throw_direction = - player.raycast_lookat.global_transform.basis.z.normalized()
		# Apply force to throw the object
		held_node.apply_central_impulse(throw_direction * player.throw_force)
		# Check if the animation player is not locked
		if !player.is_animation_locked:
			# Flag the animation player as locked
			player.is_animation_locked = true
			# Check if the player is in "third-person" perspective
			if player.perspective == 0:
				# Rotate the player to face the throwing direction
				player.visuals.look_at(
					Vector3(
						held_node.global_position.x,
						player.global_position.y,
						held_node.global_position.z,
					),
					Vector3.UP
				)
			# Play the throwing animation from the middle
			if player.animation_player.current_animation != ANIMATION_STANDING_THROWING_LEFT:
				# Play the "throwing left" animation
				player.animation_player.play(ANIMATION_STANDING_THROWING_LEFT)
				# Start playing partway through the animation
				var animation_length = player.animation_player.get_animation(ANIMATION_STANDING_THROWING_LEFT).length
				player.animation_player.seek(animation_length * 0.2)
				# Stop the animation early after a short duration
				var segment_duration = animation_length * 0.2  # Play for 20% of total length
				await get_tree().create_timer(segment_duration).timeout
				player.is_animation_locked = false
