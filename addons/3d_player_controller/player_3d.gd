extends CharacterBody3D

# Change the animation names to those in character's animation player
const animation_crawling = "Crawling_In_Place"

const animation_crouching = "Crouching_Idle"
const animation_crouching_aiming_rifle = "Rifle_Aiming_Idle_Crouching"
const animation_crouching_firing_rifle = "Rifle_Firing_Crouching"
const animation_crouching_holding_rifle = "Rifle_Idle_Crouching"
const animation_crouching_move = "Sneaking_In_Place"
const animation_crouching_move_holding_rifle = "Rifle_Walk_Crouching"
const animation_crouching_holding_tool = "Tool_Idle_Crouching"

const animation_flying = "Flying_In_Place"
const animation_flying_fast = "Flying_Fast_In_Place"

const animation_hanging = "Hanging_Idle"
const animation_hanging_shimmy_left = "Braced_Hang_Shimmy_Left_In_Place"
const animation_hanging_shimmy_right = "Braced_Hang_Shimmy_Right_In_Place"

const animation_jumping = "Falling_Idle"
const animation_jumping_holding_rifle = "Rifle_Falling_Idle"
const animation_jumping_holding_tool = "Tool_Falling_Idle"

const animation_standing = "Standing_Idle"
const animation_standing_aiming_rifle = "Rifle_Aiming_Idle"
const animation_standing_firing_rifle = "Rifle_Firing"
const animation_standing_holding_rifle = "Rifle_Low_Idle"
const animation_standing_holding_tool = "Tool_Standing_Idle"

const animation_running = "Running_In_Place"
const animation_running_aiming_rifle = "Rifle_Aiming_Run_In_Place"
const animation_running_holding_rifle = "Rifle_Low_Run_In_Place"

const animation_sprinting = "Sprinting_In_Place"
const animation_sprinting_holding_rifle = "Rifle_Sprinting_In_Place"
const animation_sprinting_holding_tool = "Tool_Sprinting_In_Place"

const animation_walking = "Walking_In_Place"
const animation_walking_aiming_rifle = "Rifle_Walking_Aiming"
const animation_walking_firing_rifle = "Rifle_Walking_Firing"
const animation_walking_holding_rifle = "Rifle_Low_Run_In_Place"
const animation_walking_holding_tool = "Tool_Walking_In_Place"

const bone_name_right_hand = "mixamorigRightHandIndex1"
const kicking_low_left = "Kicking_Low_Left"
const kicking_low_right = "Kicking_Low_Right"
const punching_high_left = "Punching_High_Left"
const punching_high_right = "Punching_High_Right"
const punching_low_left = "Punching_Low_Left"
const punching_low_right = "Punching_Low_Right"

# State machine variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_aiming: bool = false
var is_animation_locked: bool = false
var is_climbing: bool = false
var is_crawling: bool = false
var is_crouching: bool = false
var is_double_jumping: bool = false
var is_falling: bool = false
var is_firing: bool = false
var is_flying: bool = false
var is_hanging: bool = false
var is_holding: bool = false
var is_holding_rifle: bool = false
var is_holding_tool: bool = false
var is_jumping: bool = false
var is_kicking_left: bool = false
var is_kicking_right: bool = false
var is_punching_left: bool = false
var is_punching_right: bool = false
var is_running: bool = false
var is_sprinting: bool = false
var is_standing: bool = false
var is_walking: bool = false
var timer_jump: float = 0.0

# Note: `@export` variables are available for editing in the property editor.
@export var enable_crouching: bool = true
@export var enable_double_jump: bool = false
@export var enable_flying: bool = false
@export var enable_jumping: bool = true
@export var enable_kicking: bool = true
@export var enable_punching: bool = true
@export var enable_vibration: bool = false
@export var force_kicking: float = 2.0
@export var force_kicking_sprinting: float = 3.0
@export var force_punching: float = 1.0
@export var force_punching_sprinting: float = 1.5
@export var force_pushing: float = 1.0
@export var force_pushing_sprinting: float = 2.0
@export var jump_velocity: float = 4.5
@export var lock_camera: bool = false
@export var lock_movement: bool = false
@export var lock_perspective: bool = false
@export var look_sensitivity_controller: float = 120.0
@export var look_sensitivity_mouse: float = 0.2
@export var look_sensitivity_virtual: float = 60.0
@export var perspective: int = 0
@export var speed_crawling: float = 0.75
@export var speed_current: float = 3.0
@export var speed_flying: float = 5.0
@export var speed_flying_fast: float = 10.0
@export var speed_hanging: float = 0.5
@export var speed_running: float = 3.5
@export var speed_sprinting: float = 5.0
@export var speed_walking: float = 1.0
@export var zoom_max: float = 3.0
@export var zoom_min: float = 1.0
@export var zoom_speed: float = 0.2

# Note: `@onready` variables are set when the scene is loaded.
@onready var animation_player = $Visuals/AuxScene/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera = $CameraMount/Camera3D
@onready var collision_height = $CollisionShape3D.shape.height
@onready var collision_position = $CollisionShape3D.position
@onready var held_item_mount = $Visuals/HeldItemMount
@onready var item_mount = $ItemMount
@onready var player_skeleton = $Visuals/AuxScene/Node/Skeleton3D
@onready var raycast_lookat = $CameraMount/Camera3D/RayCast3D
@onready var raycast_jumptarget = $Visuals/RayCast3D_JumpTarget
@onready var raycast_top = $Visuals/RayCast3D_InFrontPlayer_Top
@onready var raycast_high = $Visuals/RayCast3D_InFrontPlayer_High
@onready var raycast_middle = $Visuals/RayCast3D_InFrontPlayer_Middle
@onready var raycast_low = $Visuals/RayCast3D_InFrontPlayer_Low
@onready var raycast_below = $Visuals/RayCast3D_BelowPlayer
@onready var visuals = $Visuals
@onready var visuals_aux_scene = $Visuals/AuxScene
@onready var visuals_aux_scene_position = $Visuals/AuxScene.position


## Called when the node leaves the scene tree.
func _exit_tree() -> void:

	# [DEBUG] Message
	if Globals.debug_mode: print(Globals.time_stamp, " [DEBUG] '", get_script().resource_path.get_file().get_basename(), "' scene unloaded.")


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# [DEBUG] Message
	if Globals.debug_mode: print(Globals.time_stamp, " [DEBUG] '", get_script().resource_path.get_file().get_basename(), "' scene loaded.")


## Called when there is an input event.
func _input(event) -> void:

	# If the game is not paused...
	if !Globals.game_paused:

		# Check if the perspective is not locked
		if !lock_perspective:

			# Check if the camera is using a third-person perspective
			if perspective == 0:

				# [zoom in] button _pressed_
				if event.is_action_pressed("zoom_in"):

					# Move the camera towards the player, slightly
					camera.transform.origin.z = clamp(camera.transform.origin.z + zoom_speed, zoom_min, zoom_max)

				# [zoom out] button _pressed_
				if event.is_action_pressed("zoom_out"):

					# Move the camera away from the player, slightly
					camera.transform.origin.z = clamp(camera.transform.origin.z - zoom_speed, zoom_min, zoom_max)

		# Check for mouse motion and the camera is not locked
		if event is InputEventMouseMotion and !lock_camera:

			# Rotate camera based on mouse movement
			camera_rotate_by_mouse(event)

		# [select] button _pressed_ and the camera is not locked
		if event.is_action_pressed("select") and !lock_camera:

			# Check if in third-person
			if perspective == 0:
				# Flag the player as in "first" person
				perspective = 1
				# Set camera's position
				camera.position = Vector3(0.0, 0.0, 0.0)
				# Set the camera's raycast position to match the camera's position
				raycast_lookat.position = Vector3(0.0, 0.0, 0.0)
				# Align visuals with the camera
				visuals.rotation = Vector3(0.0, 0.0, camera_mount.rotation.z)
				
			# Check if in first-person
			elif perspective == 1:
				# Flag the player as in "third" person
				perspective = 0
				# Set camera mount's position
				camera_mount.position = Vector3(0.0, 1.65, 0.0)
				# Set camera's position
				camera.position = Vector3(0.0, 0.6, 2.5)
				# Set the camera's raycast position to match the player's position
				raycast_lookat.position = Vector3(0.0, 0.0, -2.5)
				# Set the visual's rotation
				visuals.rotation = Vector3(0.0, 0.0, 0.0)


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
## Use _physics_process(delta) if the input needs to be checked continuously in sync with the physics engine, like for smooth movement or jump control.
func _physics_process(delta) -> void:

	# If the game is not paused...
	if !Globals.game_paused:

		# Check if no animation is playing
		if !animation_player.is_playing():

			# Flag the animation player no longer locked
			is_animation_locked = false

			# Reset player state
			is_kicking_left = false
			is_kicking_right = false
			is_punching_left = false
			is_punching_right = false

		# Handle [look_*] using controller
		var look_actions = ["look_down", "look_up", "look_left", "look_right"]
		# Check each "look" action in the list
		for action in look_actions:
			# Check if the action is _pressesd_ and the camera is not locked
			if Input.is_action_pressed(action) and !lock_camera:
				# Rotate camera based on controller movement
				camera_rotate_by_controller(delta)
	
		# Check if the player is not hanging
		if !is_hanging:

			# Add the gravity.
			velocity.y -= gravity * delta

			# Handle player movement
			update_velocity()

		# Check if the animation player is unlocked and the player's motion is unlocked
		if !is_animation_locked and !lock_movement:

			# Move player
			move_and_slide()

		# Move the camera to player
		move_camera()


## Check if the kick hits anything.
func check_kick_collision() -> void:
	# Check if the RayCast3D is collining with something
	if raycast_low.is_colliding():
		# Get the object the RayCast is colliding with
		var collider = raycast_low.get_collider()
		# Get the position of the current collision
		var collision_position = raycast_low.get_collision_point()
		# Delay execution
		await get_tree().create_timer(0.5).timeout
		# Flag the animation player no longer locked
		is_animation_locked = false
		# Reset action flag(s)
		is_kicking_left = false
		is_kicking_right = false
		# Apply force to RigidBody3D objects
		if collider is RigidBody3D:
			# Define the force to apply to the collided object
			var force = force_kicking_sprinting if is_sprinting else force_kicking
			# Define the impulse to apply
			var impulse = collision_position - collider.global_position
			# Apply the force to the object
			collider.apply_central_impulse(-impulse * force)
		# Call character functions
		if collider is CharacterBody3D:
			# Check side
			if is_kicking_left:
				# Play the appropriate hit animation
				if collider.has_method("animate_hit_low_left"):
					collider.call("animate_hit_low_left")
			else:
				# Play the appropriate hit animation
				if collider.has_method("animate_hit_low_right"):
					collider.call("animate_hit_low_right")
		# Controller vibration
		if enable_vibration:
			Input.start_joy_vibration(0, 0.0, 1.0, 0.1)


## Checks if the thrown punch hits anything.
func check_punch_collision() -> void:

	# Check if the RayCast3D is collining with something
	if raycast_middle.is_colliding():
		# Get the object the RayCast is colliding with
		var collider = raycast_middle.get_collider()
		# Get the position of the current collision
		var collision_position = raycast_middle.get_collision_point()
		# Delay execution
		await get_tree().create_timer(0.3).timeout
		# Flag the animation player no longer locked
		is_animation_locked = false
		# Reset action flag(s)
		is_punching_left = false
		is_punching_right = false
		# Apply force to RigidBody3D objects
		if collider is RigidBody3D:
			# Define the force to apply to the collided force_punching
			var force = force_punching_sprinting if is_sprinting else force_punching
			# Define the impulse to apply
			var impulse = collision_position - collider.global_position
			# Apply the force to the object
			collider.apply_central_impulse(-impulse * force)
		# Call character functions
		if collider is CharacterBody3D:
			# Check side
			if is_punching_left:
				# Play the appropriate hit animation
				if collider.has_method("animate_hit_high_left"):
					collider.call("animate_hit_high_left")
			else:
				# Play the appropriate hit animation
				if collider.has_method("animate_hit_high_right"):
					collider.call("animate_hit_high_right")
		# Controller vibration
		if enable_vibration:
			Input.start_joy_vibration(0, 1.0, 0.0, 0.1)


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
	rotation_degrees.y = rotation_degrees.y - (horizontal_input * horizontal_rotation_speed * delta)
	# Check if the player is in "third person" perspective
	if perspective == 0:
		# Rotate the visuals opposite the camera's horizontal rotation
		visuals.rotation_degrees.y = visuals.rotation_degrees.y + (horizontal_input * horizontal_rotation_speed * delta)


## Rotate camera using the mouse motion.
func camera_rotate_by_mouse(event: InputEvent) -> void:

	# Calculate the desired vertical rotation based on mouse motion
	var new_rotation_x = camera_mount.rotation_degrees.x - event.relative.y * look_sensitivity_mouse
	# Limit how far up/down the camera can rotate
	new_rotation_x = clamp(new_rotation_x, -80, 90)
	# Rotate camera up/forward and down/backward
	camera_mount.rotation_degrees.x = new_rotation_x
	
	# Update the player (visuals+camera) opposite the horizontal mouse motion
	rotate_y(deg_to_rad(-event.relative.x * look_sensitivity_mouse))
	# Check if the player is in "third person" perspective
	if perspective == 0:
		# Rotate the visuals opposite the camera's horizontal rotation
		visuals.rotate_y(deg_to_rad(event.relative.x * look_sensitivity_mouse))


## Update the camera to follow the character head's position (while in "first person").
func move_camera():

	# Check if in "first person" perspective
	if perspective == 1:
		var bone_name = "mixamorigHead"
		var bone_index = player_skeleton.find_bone(bone_name)
		# Get the overall transform of the specified bone, with respect to the player's skeleton.
		var bone_pose = player_skeleton.get_bone_global_pose(bone_index)
		# Adjust the camera mount position to match the bone's relative position (adjusting for $Visuals/AuxScene scaling)
		camera_mount.position = Vector3(-bone_pose.origin.x * 0.01, bone_pose.origin.y * 0.01, (-bone_pose.origin.z * 0.01) - 0.165)


## Update the player's velocity based on input and status.
func update_velocity() -> void:

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Calculate the input magnitude (intensity of the left-analog stick)
	var input_magnitude = input_dir.length()

	# Set the player's movement speed based on the input magnitude
	if speed_current == 0.0 and input_magnitude != 0.0:
		#speed_current = input_magnitude * speed_running 
		speed_current = speed_running # ToDo: Fine tune walking with the left-analog stick

	# Check for directional movement
	if direction:

		# Check if the animation player is unlocked
		if !is_animation_locked:

			# Check if the player is not in "third person" perspective
			if perspective == 0:

				# Update the camera to look in the direction based on player input
				visuals.look_at(position + direction)

			# Update horizontal veolicty
			velocity.x = direction.x * speed_current

			# Update vertical velocity
			velocity.z = direction.z * speed_current

	# No movement detected
	else:

		# Update horizontal veolicty
		velocity.x = move_toward(velocity.x, 0, speed_current)

		# Update vertical veolocity
		velocity.z = move_toward(velocity.z, 0, speed_current)
