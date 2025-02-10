extends BaseState

const animation_standing_holding_rifle = "Rifle_Low_Idle"
var node_name = "Holding"


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !player.game_paused:

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

				# Flag the player as "holding" something
				player.is_holding = false

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

		# Adjust the held item mount position to match the bone's relative position (adjusting for $Visuals/AuxScene 0.1 scaling)
		var bone_origin = bone_pose.origin
		var pos_x = (-bone_origin.x * 0.01) + 0.1
		var pos_y = (bone_origin.y * 0.01)
		var pos_z = (-bone_origin.z * 0.01) - 0.15
		player.held_item_mount.position = Vector3(pos_x, pos_y, pos_z)

		# Set the rotation of the held item mount to match the bone's rotation
		var bone_basis = bone_pose.basis.get_euler()
		var rot_x = -bone_basis.x + 0
		var rot_y = bone_basis.y + 0.5
		var rot_z = -bone_basis.z + 1.0

		# Apply the rotation
		player.held_item_mount.rotation = Vector3(rot_x, rot_y, rot_z)

	# Check if the player is holding a rifle
	elif player.is_holding_rifle:

		# Get the right hand bone
		var bone_name = player.bone_name_right_hand
		var bone_index = player.player_skeleton.find_bone(bone_name)

		# Get the overall transform of the specified bone, with respect to the player's skeleton.
		var bone_pose = player.player_skeleton.get_bone_global_pose(bone_index)

		# Adjust the held item mount position to match the bone's relative position (adjusting for $Visuals/AuxScene scaling)
		var bone_origin = bone_pose.origin
		var pos_x = (-bone_origin.x * 0.01)
		var pos_y = (bone_origin.y * 0.01)
		var pos_z = (-bone_origin.z * 0.01)
		player.held_item_mount.position = Vector3(pos_x, pos_y, pos_z)

		# Set the rotation of the held item mount to match the bone's rotation
		var bone_basis = bone_pose.basis.get_euler()
		var rot_x = bone_basis.x
		var rot_y = bone_basis.y - 0.2
		var rot_z = bone_basis.z + 0.33

		# Hack: Handle idle animation postional data
		if player.animation_player.current_animation == animation_standing_holding_rifle:
			rot_y = rot_y + 0.2
			rot_z = bone_basis.z - 0.75

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

		# Move the first node to the holding position
		held_node.global_transform = player.item_mount.global_transform

		# If the held node is a RigidBody, reset its velocities
		if held_node is RigidBody3D:
			held_node.linear_velocity = Vector3.ZERO
			held_node.angular_velocity = Vector3.ZERO
