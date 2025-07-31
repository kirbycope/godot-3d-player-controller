extends Node3D

var equipped := false
var initial_jump_velocity: float
var initial_shoe_position: Vector3
var initial_shoe_rotation: Vector3
var initial_shoe_2_position: Vector3
var initial_shoe_2_rotation: Vector3

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var player: CharacterBody3D
@onready var shoe: Node3D = $Shoe
@onready var shoe_2: Node3D = $Shoe2


func _ready() -> void:
	initial_shoe_position = shoe.position
	initial_shoe_rotation = shoe.rotation
	initial_shoe_2_position = shoe_2.position
	initial_shoe_2_rotation = shoe_2.rotation


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event: InputEvent) -> void:
	# [button_0] "jump" button pressed
	if event.is_action_pressed("button_0") and player != null:
		if player.is_on_floor():
			audio_stream_player_3d.play()

	# [button_13] "drop" button pressed
	elif event.is_action_pressed("button_13") and player != null:
		# Get the equipped item
		var item = player.visuals.get_node("FootMount").get_children()[0]
		# Remove the item from the player
		player.visuals.get_node("FootMount").remove_child(item)
		# Reparent the item from the player to current scene
		player.get_tree().current_scene.add_child(item)
		# Reset shoe transforms
		shoe.position = initial_shoe_position
		shoe.rotation = initial_shoe_rotation
		shoe_2.position = initial_shoe_2_position
		shoe_2.rotation = initial_shoe_2_rotation
		# Reset player properties
		player.collision_shape.position.y += 0.2
		player.shapecast.position.y += 0.2
		player.jump_velocity = initial_jump_velocity
		# Clear the references
		player = null


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if the "moon shoes" are equipped on a player
	if player != null:
		# Put "shoe_1" on LeftFoot
		var bone_name = player.BONE_NAME_LEFT_FOOT
		var bone_index = player.player_skeleton.find_bone(bone_name)
		if bone_index != -1:
			# Get the global pose of the bone
			var bone_pose = player.player_skeleton.get_bone_global_pose(bone_index)
			# Convert from skeleton's local space to world space, accounting for visuals rotation
			var skeleton_world_position = player.player_skeleton.to_global(bone_pose.origin)
			var skeleton_world_basis = player.player_skeleton.global_transform.basis * bone_pose.basis
			# Calculate rotation correction to point the shoe forward (toward toes) instead of up (along shin)
			var correction_rotation = Basis.from_euler(Vector3(-PI / 2, 0, 0)) # Rotate -90 degrees around X-axis
			var corrected_basis = skeleton_world_basis * correction_rotation
			# Apply the correction to the shoe's position and rotation
			shoe.global_position = skeleton_world_position
			shoe.global_rotation = corrected_basis.get_euler()

		# Put "shoe_2" on RightFoot
		var bone_name_2 = player.BONE_NAME_RIGHT_FOOT
		var bone_index_2 = player.player_skeleton.find_bone(bone_name_2)
		if bone_index_2 != -1:
			# Get the global pose of the bone
			var bone_pose_2 = player.player_skeleton.get_bone_global_pose(bone_index_2)
			# Convert from skeleton's local space to world space, accounting for visuals rotation
			var skeleton_world_position_2 = player.player_skeleton.to_global(bone_pose_2.origin)
			var skeleton_world_basis_2 = player.player_skeleton.global_transform.basis * bone_pose_2.basis
			# Calculate rotation correction to point the shoe forward (toward toes) instead of up (along shin)
			var correction_rotation = Basis.from_euler(Vector3(-PI / 2, 0, 0)) # Rotate -90 degrees around X-axis
			var corrected_basis_2 = skeleton_world_basis_2 * correction_rotation
			# Apply the correction to the shoe's position and rotation
			shoe_2.global_position = skeleton_world_position_2
			shoe_2.global_rotation = corrected_basis_2.get_euler()


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Reparent the held item (if any)
		body.reparent_held_item()
		# Load the scene
		var scene = load("res://scenes/moon_shoes.tscn")
		# Instantiate the scene
		var instance = scene.instantiate()
		# Set the player reference for the new skateboard instance
		instance.player = body
		# Disable the "pickup" collision
		instance.get_node("Area3D/CollisionShape3D").disabled = true
		# Add the instance to the player scene
		body.visuals.get_node("FootMount").add_child(instance)
		# Remove _this_ instance
		queue_free()
		# Modify player properties when equipping
		body.collision_shape.position.y -= 0.2
		body.shapecast.position.y -= 0.2
		initial_jump_velocity = body.jump_velocity
		body.jump_velocity = 9.0
