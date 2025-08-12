extends Node3D

const VoronoiSplitter = preload("res://scenes/voronoi_mesh_splitter.gd")

@export var mirror_mesh: MeshInstance3D
@export var num_voronoi_cells: int = 15
@export var random_seed: int = 42

# Flag to ensure mirror only shatters once
var is_shattered: bool = false

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func shatter_mirror():
	# Early exit if already shattered
	if is_shattered:
		return
	
	# Set the flag immediately to prevent re-entry
	is_shattered = true
	
	if not mirror_mesh:
		# Try to find the Quad MeshInstance3D in the Mirror3D node
		var mirror3d_node = find_child("Mirror3D")
		if mirror3d_node:
			mirror_mesh = mirror3d_node.get_node("Quad") as MeshInstance3D
		
		# If still not found, try searching more broadly
		if not mirror_mesh:
			mirror_mesh = find_child("Quad", true) as MeshInstance3D
		
		if not mirror_mesh:
			return
	
	# Generate a random seed based on current time for variation
	var time_seed = Time.get_unix_time_from_system() as int
	var final_seed = random_seed + time_seed
	
	# Split the mirror into Voronoi pieces with safety checks
	var voronoi_pieces = VoronoiSplitter.split_mesh_voronoi(mirror_mesh, num_voronoi_cells, final_seed)
	
	if voronoi_pieces.size() > 0:
		# Add the pieces to the scene as RigidBody3D objects for physics
		for i in range(voronoi_pieces.size()):
			var piece = voronoi_pieces[i]
			if not piece or not piece.mesh:
				continue
			
			var rigid_body = RigidBody3D.new()
			
			# Set collision layer and mask to ensure interaction with floor
			rigid_body.collision_layer = 1  # Default layer
			rigid_body.collision_mask = 1   # Collide with default layer (floor should be on this)
			
			# Enable contact monitoring for physics
			rigid_body.contact_monitor = true
			rigid_body.max_contacts_reported = 5
			
			# Add the mesh as a child of the rigid body
			rigid_body.add_child(piece)
			
			# Create a collision shape for the piece
			var collision_shape = CollisionShape3D.new()
			
			# Try using a simpler box collision shape first
			var box_shape = BoxShape3D.new()
			# Calculate approximate size from the mesh
			if piece.mesh:
				var aabb = piece.get_aabb()
				if aabb.size.length() > 0:
					# Make collision boxes thicker for better collision detection
					box_shape.size = Vector3(
						max(aabb.size.x, 0.1), 
						max(aabb.size.y, 0.05),  # Minimum 5cm thick instead of 1cm
						max(aabb.size.z, 0.1)
					)
					collision_shape.shape = box_shape
				else:
					# Fallback to a default small box
					box_shape.size = Vector3(0.2, 0.05, 0.2)  # Thicker fallback
					collision_shape.shape = box_shape
			else:
				box_shape.size = Vector3(0.2, 0.05, 0.2)  # Thicker default
				collision_shape.shape = box_shape
			
			rigid_body.add_child(collision_shape)
			
			# Set some physics properties for realistic shattering
			rigid_body.mass = 0.5  # Increased mass to make pieces more stable
			rigid_body.gravity_scale = 1.0
			
			# Add some random impulse to make pieces fly apart
			var rng = RandomNumberGenerator.new()
			rng.seed = final_seed + i
			var impulse = Vector3(
				rng.randf_range(-1.0, 1.0),  # Further reduced horizontal force
				rng.randf_range(0.3, 1.5),   # Further reduced upward force  
				rng.randf_range(-1.0, 1.0)   # Further reduced horizontal force
			)
			
			# Add the rigid body to the scene
			var parent_node = get_parent()
			if parent_node:
				parent_node.add_child(rigid_body)
				# Ensure piece starts close to the floor for better collision detection
				var start_position = mirror_mesh.global_position
				start_position.y = max(start_position.y, 0.5)  # At least 0.5m above floor
				rigid_body.global_position = start_position
				
				# Wait a bit longer before applying impulse to ensure physics is ready
				await get_tree().process_frame
				await get_tree().process_frame
				
				# Apply the impulse
				if is_instance_valid(rigid_body):
					rigid_body.apply_central_impulse(impulse)
				
				# Add a timer to clean up pieces after some time to prevent accumulation
				var cleanup_timer = Timer.new()
				cleanup_timer.wait_time = 30.0  # Clean up after 30 seconds
				cleanup_timer.one_shot = true
				cleanup_timer.timeout.connect(_cleanup_piece.bind(rigid_body))
				rigid_body.add_child(cleanup_timer)
				cleanup_timer.start()
		
		# Hide or remove the original mirror
		mirror_mesh.visible = false
	else:
		# Reset the flag if we failed to generate pieces
		is_shattered = false


# Clean up a mirror piece after some time
func _cleanup_piece(piece: RigidBody3D) -> void:
	if piece and is_instance_valid(piece):
		piece.queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and not is_shattered:
		shatter_mirror()
		audio_stream_player_3d.play()
