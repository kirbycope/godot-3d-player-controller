extends BaseState

const ANIMATION_CROUCHING_AIMING_RIFLE := "Rifle_Aiming_Idle_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_FIRING_RIFLE := "Rifle_Firing_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_HOLDING_RIFLE := "Rifle_Idle_Crouching" + "/mixamo_com"
const ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE := "Rifle_Walk_Crouching" + "/mixamo_com"
const ANIMATION_STANDING_AIMING_RIFLE := "Rifle_Aiming_Idle" + "/mixamo_com"
const ANIMATION_STANDING_FIRING_RIFLE := "Rifle_Firing" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_RIFLE := "Rifle_Low_Idle"  + "/mixamo_com"
const ANIMATION_STANDING_CASTING_FISHING_ROD := "Fishing_Cast" + "/mixamo_com"
const ANIMATION_STANDING_HOLDING_FISHING_ROD := "Fishing_Idle" + "/mixamo_com"
const ANIMATION_STANDING_REELING_FISHING_ROD := "Fishing_Reel" + "/mixamo_com"
const NODE_NAME := "Holding"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# [left_punch] button _pressed_ (and holding something)
		if event.is_action_pressed("left_punch") and player.is_holding:

			# Throw the held object
			throw_held_object()

		# [use] button _pressed_ (and holding something)
		if event.is_action_pressed("use") and player.is_holding:

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

				# Flag the player as "holding" something
				player.is_holding = false

				# Return so that no other input is handled
				return

		# [use] button _pressed_ (and not holding something)
		if event.is_action_pressed("use") and !player.is_holding:

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

					# Flag the player as "holding" something
					player.is_holding = true


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is holding an object
	if player.is_holding:

		# Move the held object in front of the player
		move_held_object()

	# Check if the player is holding a fishing rod, rifle, or a tool
	if player.is_holding_fishing_rod or player.is_holding_rifle or player.is_holding_tool:

		# Move the position of the held item to the player's hand
		move_held_item_mount()


## Move the item being held in the player's hand to the player's hand.
func move_held_item_mount() -> void:

	# Check if the player is holding a fishing rod
	if player.is_holding_fishing_rod:

		# Get the left hand bone
		var bone_name = player.bone_name_left_hand
		var bone_index = player.player_skeleton.find_bone(bone_name)

		# Get the overall transform of the specified bone, with respect to the player's skeleton.
		var bone_pose = player.player_skeleton.get_bone_global_pose(bone_index)

		# Get the position of the bone
		var bone_origin = bone_pose.origin
		var pos_x = (-bone_origin.x) + 0.05
		var pos_y = (bone_origin.y) + 0.1
		var pos_z = (-bone_origin.z) - 0.1

		# Set the rotation of the held item mount to match the bone's rotation
		var bone_basis = bone_pose.basis.get_euler()
		var rot_x = (-bone_basis.x)
		var rot_y = (bone_basis.y)
		var rot_z = -(bone_basis.z) - 1.25

		# Hack: Handle ANIMATION_STANDING_HOLDING_FISHING_ROD
		if player.animation_player.current_animation == ANIMATION_STANDING_HOLDING_FISHING_ROD:
			pos_x = (-bone_origin.x) + 0.05
			pos_y = (bone_origin.y) + 0.1
			pos_z = (-bone_origin.z) - 0.1
			rot_x = (-bone_basis.x)
			rot_y = (bone_basis.y)
			rot_z = (-bone_basis.z) - 1.25

		# Apply the position
		player.held_item_mount.position = Vector3(pos_x, pos_y, pos_z)

		# Apply the rotation
		player.held_item_mount.rotation = Vector3(rot_x, rot_y, rot_z)

	# Check if the player is holding a rifle
	elif player.is_holding_rifle:

		# Get the right hand bone
		var bone_name = player.bone_name_right_hand
		var bone_index = player.player_skeleton.find_bone(bone_name)

		# Get the overall transform of the specified bone, with respect to the player's skeleton.
		var bone_pose = player.player_skeleton.get_bone_global_pose(bone_index)

		# Get the position of the bone
		var bone_origin = bone_pose.origin
		var pos_x = (-bone_origin.x)
		var pos_y = (bone_origin.y)
		var pos_z = (-bone_origin.z)

		# Get the rotation of the held item mount to match the bone's rotation
		var bone_basis = bone_pose.basis.get_euler()
		var rot_x = bone_basis.x
		var rot_y = bone_basis.y
		var rot_z = bone_basis.z

		# Hack: Handle ANIMATION_CROUCHING_AIMING_RIFLE and ANIMATION_CROUCHING_HOLDING_RIFLE
		if player.animation_player.current_animation == ANIMATION_CROUCHING_AIMING_RIFLE\
		or player.animation_player.current_animation == ANIMATION_CROUCHING_FIRING_RIFLE\
		or player.animation_player.current_animation == ANIMATION_CROUCHING_HOLDING_RIFLE:
			pos_x = (-bone_origin.x) - 0.01
			pos_y = (bone_origin.y) + 0.01
			pos_z = (-bone_origin.z) - 0.15
			rot_x = bone_basis.x
			rot_y = bone_basis.y
			rot_z = bone_basis.z + 0.55

		# Hack: Handle ANIMATION_STANDING_AIMING_RIFLE and ANIMATION_STANDING_FIRING_RIFLE
		if player.animation_player.current_animation == ANIMATION_STANDING_AIMING_RIFLE\
		or player.animation_player.current_animation == ANIMATION_STANDING_FIRING_RIFLE\
		or player.animation_player.current_animation == ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE:
			pos_x = (-bone_origin.x) - 0.01
			pos_y = (bone_origin.y) + 0.01
			pos_z = (-bone_origin.z) - 0.15
			rot_x = bone_basis.x
			rot_y = bone_basis.y
			rot_z = bone_basis.z + 0.3
	
		# Hack: Handle ANIMATION_STANDING_HOLDING_RIFLE
		if player.animation_player.current_animation == ANIMATION_STANDING_HOLDING_RIFLE:
			pos_x = (-bone_origin.x) - 0.125
			pos_y = (bone_origin.y) - 0.05
			pos_z = (-bone_origin.z) - 0.03
			rot_x = bone_basis.x#
			rot_y = bone_basis.y# + 0.15
			rot_z = bone_basis.z - 0.85

		# Apply the position
		player.held_item_mount.position = Vector3(pos_x, pos_y, pos_z)
	
		# Apply the rotation
		player.held_item_mount.rotation = Vector3(rot_x, rot_y, rot_z)


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
				var shape = held_node.get_node("CollisionShape3D").shape
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
				var direction = -player.raycast_lookat.global_transform.basis.z.normalized()

				# Set the distance from the player that the object is held
				var distance = 1

				# Move the held object to the new position
				held_node.global_position = origin + (direction * distance)

		# Rotate the held item with the player
		held_node.rotation.y = player.rotation.y

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
		var throw_direction = -player.raycast_lookat.global_transform.basis.z.normalized()

		# Apply force to throw the object
		held_node.apply_central_impulse(throw_direction * player.throw_force)
