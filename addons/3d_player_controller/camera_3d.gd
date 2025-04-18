extends Camera3D

# Note: `@export` variables are available for editing in the property editor.
@export var look_sensitivity_controller: float = 120.0
@export var look_sensitivity_mouse: float = 0.2
@export var look_sensitivity_virtual: float = 60.0
@export var zoom_max: float = 3.0
@export var zoom_min: float = 1.0
@export var zoom_speed: float = 0.2

# Note: `@onready` variables are set when the scene is loaded.
@onready var camera_mount: Node3D = $".."
@onready var player: CharacterBody3D = $"../.."
@onready var retical: Control = $Retical


## Called when there is an input event.
func _input(event) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# Check if the camera is using a third-person perspective and the perspective is not locked and the camera is not locked
		if player.perspective == 0 and !player.lock_perspective and !player.lock_camera:

			# [zoom in] button _pressed_
			if event.is_action_pressed("zoom_in"):

				# Move the camera towards the player, slightly
				transform.origin.z = clamp(transform.origin.z + zoom_speed, zoom_min, zoom_max)

			# [zoom out] button _pressed_
			if event.is_action_pressed("zoom_out"):

				# Move the camera away from the player, slightly
				transform.origin.z = clamp(transform.origin.z - zoom_speed, zoom_min, zoom_max)

		# Check for mouse motion and the camera is not locked
		if event is InputEventMouseMotion and !player.lock_camera:

			# Check if the mouse is captured
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:

				# Rotate camera based on mouse movement
				camera_rotate_by_mouse(event)

		# [select] button _pressed_ and the camera is not locked
		if event.is_action_pressed("select") and !player.lock_camera:

			# Check if in third-person
			if player.perspective == 0:

				# Switch to "first" person perspective
				switch_to_first_person()

			# Check if in first-person
			elif player.perspective == 1:

				# Switch to "third" person perspective
				switch_to_third_person()


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
## Use _physics_process(delta) if the input needs to be checked continuously in sync with the physics engine, like for smooth movement or jump control.
func _physics_process(delta) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# If the game is not paused...
	if !player.game_paused:

		# Handle [look_*] using controller
		var look_actions = ["look_down", "look_up", "look_left", "look_right"]

		# Check each "look" action in the list
		for action in look_actions:

			# Check if the action is _pressed_ and the camera is not locked
			if Input.is_action_pressed(action) and !player.lock_camera:

				# Rotate camera based on controller movement
				camera_rotate_by_controller(delta)

		# Move the camera to player
		move_camera()


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


## Rotate camera using the mouse motion.
func camera_rotate_by_mouse(event: InputEvent) -> void:

	# Calculate the desired vertical rotation based on mouse motion
	var new_rotation_x = camera_mount.rotation_degrees.x - event.relative.y * look_sensitivity_mouse

	# Limit how far up/down the camera can rotate
	new_rotation_x = clamp(new_rotation_x, -80, 90)

	# Rotate camera up/forward and down/backward
	camera_mount.rotation_degrees.x = new_rotation_x

	# Update the player (visuals+camera) opposite the horizontal mouse motion
	player.rotate_y(deg_to_rad(-event.relative.x * look_sensitivity_mouse))

	# Check if the player is in "third person" perspective
	if player.perspective == 0:

		# Rotate the visuals opposite the camera's horizontal rotation
		player.visuals.rotate_y(deg_to_rad(event.relative.x * look_sensitivity_mouse))


## Update the camera to follow the character head's position (while in "first person").
func move_camera():

	# Check if in "first person" perspective
	if player.perspective == 1:

		# Get the index of the bone in the player's skeleton
		var bone_index = player.player_skeleton.find_bone(player.bone_name_head)

		# Get the overall transform of the specified bone, with respect to the player's skeleton.
		var bone_pose = player.player_skeleton.get_bone_global_pose(bone_index)

		# Adjust the camera mount position to match the bone's relative position (adjusting for $Visuals/AuxScene scaling)
		camera_mount.position = Vector3(-bone_pose.origin.x, bone_pose.origin.y, -bone_pose.origin.z)


## Switches the player perspective to "first" person.
func switch_to_first_person() -> void:

	# Flag the player as in "first" person
	player.perspective = 1

	# Set camera's position
	position = Vector3(0.0, 0.1, 0.0)

	# Set the camera's raycast position to match the camera's position
	player.raycast_lookat.position = Vector3.ZERO

	# Align visuals with the camera
	player.visuals.rotation = Vector3(0.0, 0.0, camera_mount.rotation.z)

	# Show the retical
	retical.show()


## Switches the player perspective to "third" person.
func switch_to_third_person() -> void:

	# Flag the player as in "third" person
	player.perspective = 0

	# Set camera mount's position
	camera_mount.position = Vector3(0.0, 1.65, 0.0)

	# Set camera's position
	position = Vector3(0.0, 0.6, 2.5)

	# Set the camera's raycast position to match the player's position
	player.raycast_lookat.position = Vector3(0.0, 0.0, -2.5)

	# Set the visual's rotation
	player.visuals.rotation = Vector3.ZERO

	# Hide the retical
	retical.hide()
