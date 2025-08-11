extends StaticBody3D

## The size of the mirror quad mesh in units.
@export var size: Vector2 = Vector2(2, 2) :
	set(value):
		config_dirty = true
		size = value

## The number of pixels to render per unit.
@export var pixels_per_unit: int = 200 :
	set(value):
		config_dirty = true
		pixels_per_unit = value

## If true, uses a linear (anti-aliased) filter, otherwise, uses a nearest (aliased) filter.
@export var use_linear_filter: bool = true :
	set(value):
		config_dirty = true
		use_linear_filter = value

## The modulate applied to the mirror.
@export var color: Color = Color(0.9, 0.97, 0.94) :
	set(value):
		config_dirty = true
		color = value

## The amount to use the distortion texture.
@export_range(0, 100, 0.01) var distortion: float = 0.0 :
	set(value):
		config_dirty = true
		distortion = value

## The noise texture to distort the mirror with.
@export var distortion_texture: Texture2D = null :
	set(value):
		config_dirty = true
		distortion_texture = value

## The visibility layers rendered by the mirror.
@export_flags_3d_render var cull_mask: int = 0xFFFFF :
	set(value):
		config_dirty = true
		cull_mask = value

## The minimum distance of objects the mirror will render.
@export var cull_near: float = 0.05

## The maximum distance of objects the mirror will render.
@export var cull_far: float = 50.0

## The maximum distance of the player camera before the mirror is frozen.
@export var freeze_distance: float = 50.0

## The maximum number of mirror updates per second. If negative, unlimited.
@export var max_fps: float = -1.0

## The viewport used to render the mirror.
@onready var mirror_viewport: SubViewport = $SubViewport

## The viewport camera used to sample the mirror.
@onready var mirror_camera: Camera3D = $SubViewport/Camera3D

## The quad mesh instance used to display the mirror.
@onready var mirror_quad: MeshInstance3D = $MeshInstance3D

## If true, the mirror will be reconfigured on the next frame.
var config_dirty: bool = true

## The number of seconds since the mirror was updated.
var time_since_update: float = 0.0

## If true, the mirror will be updated on the next frame regardless of max_fps.
var time_update_dirty: bool = true

## Updates the mirror.
func _process(delta: float) -> void:
	# Ensure visible
	if !is_visible_in_tree():
		return
	
	# Get player camera viewing mirror
	var player_camera: Camera3D
	if Engine.is_editor_hint():
		var editor_interface = Engine.get_singleton(&"EditorInterface")
		if editor_interface:
			player_camera = editor_interface.get_editor_viewport_3d(0).get_camera_3d()
	else:
		player_camera = get_viewport().get_camera_3d()
	
	# Ensure player camera exists
	if !is_instance_valid(player_camera):
		return
	
	# Ensure enough time passed since last update
	if time_update_dirty:
		time_update_dirty = false
	else:
		if max_fps >= 0:
			time_since_update += delta
			if time_since_update < 1.0 / max_fps:
				mirror_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
				return
	
	mirror_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	time_since_update = 0
	
	# Freeze mirror if player is far away
	if global_position.distance_to(player_camera.global_position) >= freeze_distance:
		mirror_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return
	else:
		mirror_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	
	# Configure mirror
	if config_dirty:
		config_dirty = false
		_configure_mirror()
	
	# Transform mirror camera to opposite side of mirror plane
	var mirror_normal: Vector3 = mirror_quad.global_basis.z
	var mirror_transform: Transform3D = get_mirror_transform(mirror_normal, mirror_quad.global_position)
	mirror_camera.global_transform = mirror_transform * player_camera.global_transform
	
	# Look perpendicular into mirror plane for frustum camera
	mirror_camera.global_transform = mirror_camera.global_transform.looking_at(
		(mirror_camera.global_position / 2.0) + (player_camera.global_position / 2.0),
		mirror_quad.global_basis.y
	)
	var camera_to_mirror_offset: Vector3 = mirror_quad.global_position - mirror_camera.global_position
	
	# Get near and far cull distances
	var near: float = abs(camera_to_mirror_offset.dot(mirror_normal)) + cull_near
	var far: float = camera_to_mirror_offset.length() + cull_far
	
	# Transform offset to camera's local coordinate system (frustum offset uses local space)
	var cam_to_mirror_offset_camera_local: Vector3 = mirror_camera.global_basis.inverse() * camera_to_mirror_offset
	var frustum_offset := Vector2(cam_to_mirror_offset_camera_local.x, cam_to_mirror_offset_camera_local.y)
	
	# Set frustum camera
	mirror_camera.set_frustum(size.x, frustum_offset, near, far)

## Configures the mirror's appearance and rendering settings.
func _configure_mirror() -> void:
	if !mirror_viewport || !mirror_camera || !mirror_quad:
		return
	
	var viewport_texture: ViewportTexture = mirror_viewport.get_texture()
	var quad_material: ShaderMaterial = mirror_quad.get_active_material(0) as ShaderMaterial
	
	if !quad_material:
		return
	
	# Configure camera
	mirror_camera.cull_mask = cull_mask
	
	# Configure quad mesh
	if mirror_quad.mesh is QuadMesh:
		var quad_mesh = mirror_quad.mesh as QuadMesh
		quad_mesh.size = size
	elif mirror_quad.mesh is PlaneMesh:
		var plane_mesh = mirror_quad.mesh as PlaneMesh
		plane_mesh.size = size
	
	# Configure viewport
	mirror_viewport.size = size * pixels_per_unit
	
	# Configure shader parameters
	quad_material.set_shader_parameter(&"color", color)
	quad_material.set_shader_parameter(&"distortion_texture", distortion_texture)
	quad_material.set_shader_parameter(&"distortion_strength", distortion)
	quad_material.set_shader_parameter(&"mirror_texture_linear", viewport_texture if use_linear_filter else null)
	quad_material.set_shader_parameter(&"mirror_texture_nearest", viewport_texture if !use_linear_filter else null)
	quad_material.set_shader_parameter(&"use_mirror_texture_linear", use_linear_filter)

## Calculates the transformation that mirrors through the plane with the normal and offset.
static func get_mirror_transform(normal: Vector3, offset: Vector3) -> Transform3D:
	var basis_x: Vector3 = Vector3(1, 0, 0) - (2 * Vector3(normal.x * normal.x, normal.x * normal.y, normal.x * normal.z))
	var basis_y: Vector3 = Vector3(0, 1, 0) - (2 * Vector3(normal.y * normal.x, normal.y * normal.y, normal.y * normal.z))
	var basis_z: Vector3 = Vector3(0, 0, 1) - (2 * Vector3(normal.z * normal.x, normal.z * normal.y, normal.z * normal.z))
	var origin: Vector3 = 2 * normal.dot(offset) * normal
	return Transform3D(basis_x, basis_y, basis_z, origin)

## Forces the mirror to update its configuration on the next frame.
func mark_config_dirty() -> void:
	config_dirty = true

## Forces the mirror to update on the next frame regardless of max_fps.
func force_update() -> void:
	time_update_dirty = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		print("shattering mirror")
		# ToDo shatter mirror
		# Split MeshInstance3D into Voronoi shards
