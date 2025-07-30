extends Node3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var player = get_parent().get_node("Player")
@onready var shoe: Node3D = $Shoe
@onready var shoe_2: Node3D = $Shoe2


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.collision_shape.position.y -= 0.2
	player.shapecast.position.y -= 0.2
	player.jump_velocity = 9.0


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event: InputEvent) -> void:
	# [button_0] "jump" button pressed
	if event.is_action_pressed("button_0") and player.is_on_floor():
		audio_stream_player_3d.play()


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Make sure the player and skeleton exist
	if not player or not player.player_skeleton:
		return
	
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
