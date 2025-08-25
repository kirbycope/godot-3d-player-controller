extends Camera3D

# Note: `@export` variables are available for editing in the property editor.
@export var look_sensitivity_controller: float = 120.0
@export var look_sensitivity_mouse: float = 0.2
@export var look_sensitivity_virtual: float = 60.0
@export var zoom_max: float = 1.0
@export var zoom_min: float = 1.0
@export var zoom_speed: float = 0.2
@export var smoothing_enabled: bool = true
@export var smoothing_speed_y: float = 8.0

# Note: `@onready` variables are set when the scene is loaded.
@onready var camera_mount: Node3D = get_parent()
@onready var player: CharacterBody3D = get_parent().get_parent()
@onready var retical: Control = $Retical

# Zoom offset for third person camera
var zoom_offset: float = 0.0
# Target position for smooth camera movement
var target_position: Vector3


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set camera as top level
	set_as_top_level(true)
	
	# Set the camera's raycast to ignore collisions with the player
	$RayCast3D.add_exception(player)


## Called when there is an input event.
func _input(event) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# Check if the camera is using a third-person perspective and the perspective is not locked and the camera is not locked
		if player.perspective == 0 and !player.lock_perspective and !player.lock_camera:
			# [zoom in] button _pressed_
			if event.is_action_pressed("button_10"):
				# Move the camera towards the player, slightly
				zoom_offset = clamp(zoom_offset + zoom_speed, -zoom_max, zoom_max)

			# [zoom out] button _pressed_
			if event.is_action_pressed("button_11"):
				# Move the camera away from the player, slightly
				zoom_offset = clamp(zoom_offset - zoom_speed, -zoom_max, zoom_max)

		# Check for mouse motion and the camera is not locked
		if event is InputEventMouseMotion and !player.lock_camera:
			# Check if the mouse is captured
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				# Rotate camera based on mouse movement
				camera_rotate_by_mouse(event)

		# [select] button _pressed_ and the camera is not locked
		if event.is_action_pressed("button_8") and !player.lock_camera:
			# Check if in third-person
			if player.perspective == 0:
				# Switch to "first" person perspective
				switch_to_first_person()

			# Check if in first-person
			elif player.perspective == 1:
				# Switch to "third" person perspective
				switch_to_third_person()


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
func _physics_process(delta) -> void:
	# Handle input-driven look controls only when the game is not paused
	var look_actions = ["look_down", "look_up", "look_left", "look_right"]
	if !player.game_paused:
		for action in look_actions:
			if Input.is_action_pressed(action) and !player.lock_camera:
				camera_rotate_by_controller(delta)

	# ALWAYS update the camera position/rotation to follow the player
	# (the follow behaviour must run even while the game is paused)
	if player.perspective == 1:
		move_camera_to_head()
	else:
		follow_camera_mount(delta)

	# Update raycast position regardless of pause state so the camera look
	# origin stays consistent with the player's head
	update_raycast_position()


## Follow the camera mount position and rotation (for third person)
func follow_camera_mount(delta: float) -> void:
	# Check if the camera mount exists
	if camera_mount != null:
		# Copy the camera mount's global transform for rotation
		global_transform.basis = camera_mount.global_transform.basis
		# Get the starting position of the CameraMount
		var base_offset = Vector3(0.0, 0.3333 * player.collision_height, 1.6666 * player.collision_height)
		# Get the amount to offset the camera based on zoom in/out
		var zoom_vector = Vector3(0.0, 0.0, zoom_offset)
		# Calculate the target position
		target_position = camera_mount.global_position + camera_mount.global_transform.basis * (base_offset + zoom_vector)
		# Apply smoothing (if enabled)
		if smoothing_enabled and player.raycast_below.is_colliding() and player.velocity != Vector3.ZERO and !player.is_climbing and !player.is_driving and !player.is_falling and !player.is_flying and !player.is_hanging and !player.is_jumping and !player.is_shimmying:
			# Get the current position of the Camera3D
			var current_position = global_position
			# Smooth only the y-axis position
			var smooth_y = lerp(current_position.y, target_position.y, smoothing_speed_y * delta)
			# Set the new position based on lerp value
			global_position = Vector3(target_position.x, smooth_y, target_position.z)
		# Smoothing must not be enabled
		else:
			# No smoothing, directly set position
			global_position = target_position


## Rotate camera using the right-analog stick.
func camera_rotate_by_controller(delta: float) -> void:
	# Get the intensity of each action 
	var look_up = Input.get_action_strength("look_up")
	var look_down = Input.get_action_strength("look_down")
	var look_left = Input.get_action_strength("look_left")
	var look_right = Input.get_action_strength("look_right")
	# Calculate the input strength for vertical and horizontal movement
	var vertical_input = look_up - look_down
	var horizontal_input = look_right - look_left
	# Calculate the rotation speed based on the input strength
	var vertical_rotation_speed = abs(vertical_input)
	var horizontal_rotation_speed = abs(horizontal_input)
	# Check if the player is using a controller
	if Input.is_joy_known(0):
		# Adjust rotation speed based on input intensity (magnitude of the right-stick movement)
		vertical_rotation_speed *= look_sensitivity_controller
		horizontal_rotation_speed *= look_sensitivity_controller
	# The input must have been triggerd by a touch event
	else:
		# Adjust rotation speed based on input intensity (magnitude of the touch-drag movement)
		vertical_rotation_speed *= look_sensitivity_virtual
		horizontal_rotation_speed *= look_sensitivity_virtual
	# Calculate the desired vertical rotation based on controller motion
	var new_rotation_x = camera_mount.rotation_degrees.x + (vertical_input * vertical_rotation_speed * delta)
	# Limit how far up/down the camera can rotate
	new_rotation_x = clamp(new_rotation_x, -80, 90)
	# Rotate camera up/forward and down/backward
	camera_mount.rotation_degrees.x = new_rotation_x
	# Update the player (visuals+camera) opposite the horizontal controller motion
	player.rotation_degrees.y = player.rotation_degrees.y - (horizontal_input * horizontal_rotation_speed * delta)
	# Check if the player is in "third person" perspective
	if player.perspective == 0:
		# Rotate the visuals opposite the camera's horizontal rotation
		player.visuals.rotation_degrees.y = player.visuals.rotation_degrees.y + (horizontal_input * horizontal_rotation_speed * delta)
		# Move camera to follow camera_mount after rotation
		follow_camera_mount(delta)


## Rotate camera using the mouse motion.
func camera_rotate_by_mouse(event: InputEvent) -> void:
	# Calculate the desired vertical rotation based on mouse motion
	var new_rotation_x = camera_mount.rotation_degrees.x - event.relative.y * look_sensitivity_mouse
	# Limit how far up/down the camera can rotate
	new_rotation_x = clamp(new_rotation_x, -80, 90)
	# Rotate camera up/forward and down/backward
	camera_mount.rotation_degrees.x = new_rotation_x
	# Update the player and camera opposite the horizontal mouse motion
	player.rotate_y(deg_to_rad(-event.relative.x * look_sensitivity_mouse))
	# Check if the player is in "third person" perspective or the player is "hanging"
	if player.perspective == 0 or player.is_hanging:
		# Rotate the visuals with the camera's horizontal rotation
		player.visuals.rotate_y(deg_to_rad(event.relative.x * look_sensitivity_mouse))
		# Move camera to follow camera_mount after rotation (only in third person)
		if player.perspective == 0:
			follow_camera_mount(get_physics_process_delta_time())


## Update the camera to follow the character head's position (while in "first person").
func move_camera_to_head():
	# Get the index of the bone in the player's skeleton
	var bone_index = player.player_skeleton.find_bone(player.BONE_NAME_HEAD)
	# Get the overall transform of the specified bone, with respect to the player's skeleton
	var bone_pose = player.player_skeleton.get_bone_global_pose(bone_index)
	# Convert the bone's local position to world space
	var bone_world_pos = player.player_skeleton.global_transform * bone_pose.origin
	# Set the camera's position to the bone's world position
	global_position = bone_world_pos
	# Copy the camera mount's rotation for consistent look direction
	global_rotation = camera_mount.global_rotation
	# Apply an offset in the camera's look direction
	global_position += global_transform.basis.z * -0.1


## Updates the raycast position to always originate from the player's head and look where the camera is looking
func update_raycast_position() -> void:
	if player.raycast_lookat and player.player_skeleton:
		# Get the head bone position
		var head_bone_index = player.player_skeleton.find_bone(player.BONE_NAME_HEAD)
		if head_bone_index != -1:
			# Get the head bone's world position
			var head_bone_pose = player.player_skeleton.get_bone_global_pose(head_bone_index)
			var head_world_pos = player.player_skeleton.global_transform * head_bone_pose.origin
			
			# Set the raycast's global position to the head position
			player.raycast_lookat.global_position = head_world_pos
			
			# Set the raycast's rotation to match the camera's rotation (looking where camera looks)
			player.raycast_lookat.global_rotation = global_rotation


## Switches the player perspective to "first" person.
func switch_to_first_person() -> void:
	# Flag the player as in "first" person
	player.perspective = 1

	# Align visuals with the camera
	player.visuals.rotation = Vector3(0.0, 0.0, camera_mount.rotation.z)

	# Show the retical
	retical.show()


## Switches the player perspective to "third" person.
func switch_to_third_person() -> void:
	# Flag the player as in "third" person
	player.perspective = 0

	# Set the visual's rotation
	player.visuals.rotation = Vector3.ZERO

	# Hide the retical
	retical.hide()
