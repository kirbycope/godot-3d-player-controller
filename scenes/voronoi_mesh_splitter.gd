extends RefCounted

# Voronoi Mesh Splitter for Godot 4.5
# Splits a quad MeshInstance3D into Voronoi diagram pieces

# Voronoi cell structure
class VoronoiCell:
	var center: Vector2
	var vertices: PackedVector2Array
	var bounds: Rect2
	
	func _init(c: Vector2):
		center = c
		vertices = PackedVector2Array()

# Main function to split a MeshInstance3D into Voronoi pieces
static func split_mesh_voronoi(mesh_instance: MeshInstance3D, num_cells: int = 10, seed_value: int = 42) -> Array[MeshInstance3D]:
	if not mesh_instance or not mesh_instance.mesh:
		push_error("Invalid MeshInstance3D or mesh")
		return []
	
	# Get the original mesh bounds
	var aabb = mesh_instance.get_aabb()
	
	# Special handling for QuadMesh
	var bounds: Rect2
	if mesh_instance.mesh is QuadMesh:
		var quad_mesh = mesh_instance.mesh as QuadMesh
		var quad_size = quad_mesh.size
		# Create bounds based on the quad size, centered around origin
		bounds = Rect2(
			Vector2(-quad_size.x / 2.0, -quad_size.y / 2.0),
			quad_size
		)
	else:
		# Use AABB for other mesh types
		bounds = Rect2(
			Vector2(aabb.position.x, aabb.position.z),
			Vector2(aabb.size.x, aabb.size.z)
		)
	
	# Ensure bounds are valid
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		return []
	
	# Generate Voronoi diagram
	var cells = generate_voronoi_cells(bounds, num_cells, seed_value)
	
	# Create mesh pieces for each Voronoi cell
	var result_meshes: Array[MeshInstance3D] = []
	
	for i in range(cells.size()):
		var cell = cells[i]
		var new_mesh_instance = create_mesh_from_cell(mesh_instance, cell, bounds)
		if new_mesh_instance:
			new_mesh_instance.name = "VoronoiPiece_" + str(i)
			result_meshes.append(new_mesh_instance)
	
	return result_meshes

# Generate Voronoi cells using Lloyd's algorithm
static func generate_voronoi_cells(bounds: Rect2, num_cells: int, seed_value: int) -> Array[VoronoiCell]:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Generate random seed points
	var points: Array[Vector2] = []
	for i in range(num_cells):
		var x = rng.randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
		var y = rng.randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		points.append(Vector2(x, y))
	
	# Apply Lloyd's relaxation (optional, for better distribution)
	for iteration in range(2):
		points = lloyd_relaxation(points, bounds)
	
	# Generate Voronoi cells
	var cells: Array[VoronoiCell] = []
	for point in points:
		var cell = VoronoiCell.new(point)
		cell.vertices = compute_voronoi_cell_vertices(point, points, bounds)
		cells.append(cell)
	
	return cells

# Lloyd's relaxation for better point distribution
static func lloyd_relaxation(points: Array[Vector2], bounds: Rect2) -> Array[Vector2]:
	var new_points: Array[Vector2] = []
	
	for i in range(points.size()):
		var current_point = points[i]
		var cell_vertices = compute_voronoi_cell_vertices(current_point, points, bounds)
		
		# Calculate centroid of the cell
		var centroid = Vector2.ZERO
		if cell_vertices.size() > 0:
			for vertex in cell_vertices:
				centroid += vertex
			centroid /= cell_vertices.size()
			new_points.append(centroid)
		else:
			new_points.append(current_point)
	
	return new_points

# Compute vertices of a Voronoi cell using half-plane intersections
static func compute_voronoi_cell_vertices(center: Vector2, all_points: Array[Vector2], bounds: Rect2) -> PackedVector2Array:
	# Start with the bounding rectangle
	var cell_vertices = PackedVector2Array([
		bounds.position,
		Vector2(bounds.position.x + bounds.size.x, bounds.position.y),
		bounds.position + bounds.size,
		Vector2(bounds.position.x, bounds.position.y + bounds.size.y)
	])
	
	# Clip against half-planes defined by other Voronoi sites
	for other_point in all_points:
		if other_point == center:
			continue
		
		# Create half-plane (perpendicular bisector)
		var mid_point = (center + other_point) * 0.5
		var normal = (center - other_point).normalized()
		
		# Clip the current polygon against this half-plane
		cell_vertices = sutherland_hodgman_clip(cell_vertices, mid_point, normal)
		
		if cell_vertices.size() < 3:
			break
	
	return cell_vertices

# Sutherland-Hodgman polygon clipping algorithm
static func sutherland_hodgman_clip(vertices: PackedVector2Array, plane_point: Vector2, plane_normal: Vector2) -> PackedVector2Array:
	if vertices.size() == 0:
		return PackedVector2Array()
	
	var output_vertices = PackedVector2Array()
	
	if vertices.size() > 0:
		var prev_vertex = vertices[vertices.size() - 1]
		
		for i in range(vertices.size()):
			var current_vertex = vertices[i]
			
			var prev_inside = is_point_inside_half_plane(prev_vertex, plane_point, plane_normal)
			var current_inside = is_point_inside_half_plane(current_vertex, plane_point, plane_normal)
			
			if current_inside:
				if not prev_inside:
					# Entering the half-plane
					var intersection = line_plane_intersection(prev_vertex, current_vertex, plane_point, plane_normal)
					if intersection != Vector2.INF:
						output_vertices.append(intersection)
				output_vertices.append(current_vertex)
			elif prev_inside:
				# Exiting the half-plane
				var intersection = line_plane_intersection(prev_vertex, current_vertex, plane_point, plane_normal)
				if intersection != Vector2.INF:
					output_vertices.append(intersection)
			
			prev_vertex = current_vertex
	
	return output_vertices

# Check if a point is inside a half-plane
static func is_point_inside_half_plane(point: Vector2, plane_point: Vector2, plane_normal: Vector2) -> bool:
	return (point - plane_point).dot(plane_normal) >= 0

# Find intersection between a line segment and a plane
static func line_plane_intersection(p1: Vector2, p2: Vector2, plane_point: Vector2, plane_normal: Vector2) -> Vector2:
	var line_dir = p2 - p1
	var denom = line_dir.dot(plane_normal)
	
	if abs(denom) < 1e-6:
		return Vector2.INF  # Line is parallel to plane
	
	var t = (plane_point - p1).dot(plane_normal) / denom
	if t >= 0.0 and t <= 1.0:
		return p1 + t * line_dir
	
	return Vector2.INF  # No intersection within segment

# Create a MeshInstance3D from a Voronoi cell
static func create_mesh_from_cell(original_mesh: MeshInstance3D, cell: VoronoiCell, bounds: Rect2) -> MeshInstance3D:
	if cell.vertices.size() < 3:
		return null
	
	# Create new MeshInstance3D
	var new_mesh_instance = MeshInstance3D.new()
	
	# Copy transform from original
	new_mesh_instance.transform = original_mesh.transform
	
	# Create ArrayMesh
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	# Triangulate the Voronoi cell
	var triangulated_vertices = triangulate_polygon(cell.vertices)
	
	if triangulated_vertices.size() < 9:  # Need at least 3 triangles worth of vertices
		return null
	
	# Convert 2D vertices to 3D (assuming Y=0 for a flat quad)
	var vertices_3d = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	# Get original mesh bounds for UV mapping
	var _original_aabb = original_mesh.get_aabb()
	
	for vertex_2d in triangulated_vertices:
		# Convert to 3D space
		var vertex_3d = Vector3(vertex_2d.x, 0, vertex_2d.y)
		vertices_3d.append(vertex_3d)
		
		# Normal pointing up
		normals.append(Vector3.UP)
		
		# Calculate UV coordinates
		var uv = Vector2(
			(vertex_2d.x - bounds.position.x) / bounds.size.x,
			(vertex_2d.y - bounds.position.y) / bounds.size.y
		)
		uvs.append(uv)
	
	arrays[Mesh.ARRAY_VERTEX] = vertices_3d
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	# Create the mesh surface
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	new_mesh_instance.mesh = array_mesh
	
	# Copy material from original mesh
	# First try to get the material from the mesh surface
	var original_material = null
	if original_mesh.mesh and original_mesh.mesh.get_surface_count() > 0:
		original_material = original_mesh.mesh.surface_get_material(0)
	
	# If no surface material, try material_override
	if not original_material:
		original_material = original_mesh.material_override
	
	# If we found a material, apply it to our new mesh
	if original_material:
		# Clone the material to avoid sharing issues
		var cloned_material = original_material.duplicate()
		
		# Add slight emission to make pieces more visible
		if cloned_material is ShaderMaterial:
			# For shader materials, we can't easily modify emission, so just use as-is
			pass
		elif cloned_material is StandardMaterial3D:
			var std_mat = cloned_material as StandardMaterial3D
			std_mat.emission_enabled = true
			std_mat.emission = Color(0.1, 0.1, 0.1)  # Slight white glow
		
		# Apply to both mesh surface and override for safety
		array_mesh.surface_set_material(0, cloned_material)
		new_mesh_instance.material_override = cloned_material
	else:
		# Create a fallback material so pieces are at least visible
		var fallback_material = StandardMaterial3D.new()
		fallback_material.albedo_color = Color(0.8, 0.9, 1.0, 0.8)  # Light blue, slightly transparent
		fallback_material.emission_enabled = true
		fallback_material.emission = Color(0.2, 0.2, 0.3)
		array_mesh.surface_set_material(0, fallback_material)
		new_mesh_instance.material_override = fallback_material
	
	return new_mesh_instance

# Simple ear clipping triangulation for convex polygons
static func triangulate_polygon(vertices: PackedVector2Array) -> PackedVector2Array:
	if vertices.size() < 3:
		return PackedVector2Array()
	
	var triangulated = PackedVector2Array()
	
	# For convex polygons, we can use a simple fan triangulation
	# Make sure vertices are ordered counter-clockwise for proper normal direction
	var area = 0.0
	for i in range(vertices.size()):
		var j = (i + 1) % vertices.size()
		area += (vertices[j].x - vertices[i].x) * (vertices[j].y + vertices[i].y)
	
	# If area is positive, vertices are clockwise, so we need to reverse them
	var ordered_vertices = vertices
	if area > 0:
		ordered_vertices = PackedVector2Array()
		for i in range(vertices.size() - 1, -1, -1):
			ordered_vertices.append(vertices[i])
	
	# Create triangles with counter-clockwise winding
	for i in range(1, ordered_vertices.size() - 1):
		triangulated.append(ordered_vertices[0])
		triangulated.append(ordered_vertices[i])
		triangulated.append(ordered_vertices[i + 1])
	
	return triangulated
