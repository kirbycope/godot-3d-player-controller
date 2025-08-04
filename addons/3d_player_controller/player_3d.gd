extends CharacterBody3D

const BONE_NAME_HEAD = "Head"
const BONE_NAME_LEFT_HAND = "LeftHand"
const BONE_NAME_RIGHT_HAND = "RightIndexProximal" # Right hand index finger proximal bone
const BONE_NAME_LEFT_FOOT = "LeftFoot"
const BONE_NAME_RIGHT_FOOT = "RightFoot"
const STATES = preload("res://addons/3d_player_controller/states/states.gd")

# Note: `@export` variables are available for editing in the property editor.
@export var current_state: STATES.State = STATES.State.STANDING
@export var enable_chat: bool = true
@export var enable_emotes: bool = true
@export var enable_climbing: bool = true
@export var enable_crouching: bool = true
@export var enable_double_jump: bool = false
@export var enable_flying: bool = false
@export var enable_jumping: bool = true
@export var enable_kicking: bool = true
@export var enable_noclip: bool = false
@export var enable_punching: bool = true
@export var enable_sprinting: bool = true
@export var enable_vibration: bool = false
@export var friction_skateboarding: float = 0.01
@export var force_kicking: float = 2.0
@export var force_kicking_sprinting: float = 3.0
@export var force_punching: float = 1.0
@export var force_punching_sprinting: float = 1.5
@export var force_pushing: float = 0.2
@export var force_pushing_sprinting: float = 0.4
@export var force_pushing_multiplier: float = 1.0  ## Global multiplier for all pushing/hitting forces
@export var game_paused: bool = false
@export var jump_velocity: float = 4.5
@export var lock_camera: bool = false
@export var lock_movement_x: bool = false
@export var lock_movement_y: bool = false
@export var lock_perspective: bool = false
@export var perspective: int = 0 ## 0 = Third Person, 1 = First Person
@export var speed_climbing: float = 0.5
@export var speed_crawling: float = 0.75
@export var speed_current: float = 3.0
@export var speed_flying: float = 5.0
@export var speed_flying_fast: float = 10.0
@export var speed_hanging: float = 0.5
@export var speed_running: float = 3.5
@export var speed_sprinting: float = 5.0
@export var speed_swimming: float = 3.0
@export var speed_walking: float = 1.0
@export var throw_force: float = 3.5

# State machine variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_aiming: bool = false
var is_animation_locked: bool = false
var is_casting: bool = false
var is_climbing: bool = false
var is_crawling: bool = false
var is_crouching: bool = false
var is_double_jumping: bool = false
var is_driving: bool = false
var is_driving_in ## The Node the player is driving
var is_falling: bool = false
var is_firing: bool = false
var is_flying: bool = false
var is_hanging: bool = false
var is_holding: bool = false
var is_holding_onto ## The Node held in a player's hand
var is_holding_fishing_rod: bool = false
var is_holding_rifle: bool = false
var is_holding_tool: bool = false
var is_jumping: bool = false
var is_kicking_left: bool = false
var is_kicking_right: bool = false
var is_punching_left: bool = false
var is_punching_right: bool = false
var is_reeling: bool = false
var is_rotating_object: bool = false
var is_running: bool = false
var is_shimmying: bool = false
var is_skateboarding: bool = false
var is_skateboarding_on ## The Node the player is skateboarding on
var is_sprinting: bool = false
var is_standing: bool = false
var is_swimming_in ## The Node the player is swimming in
var is_swimming: bool = false
var is_using: bool = false
var is_walking: bool = false
var virtual_velocity: Vector3 = Vector3.ZERO

# Note: `@onready` variables are set when the scene is loaded.
# Audio and Animation
@onready var animation_player = $Visuals/AuxScene/AnimationPlayer
@onready var audio_player = $AudioStreamPlayer3D
# State Management
@onready var base_state: BaseState = $States/Base
# Camera and Mount
@onready var camera_mount = $CameraMount
@onready var camera = camera_mount.get_node("Camera3D")
# UI Elements
@onready var chat_window = camera.get_node("ChatWindow")
@onready var menu_pause = camera.get_node("Pause")
@onready var menu_settings = menu_pause.get_node("../Settings")
# Collision and Physics
@onready var collision_shape = $CollisionShape3D
@onready var collision_height = collision_shape.shape.height
@onready var collision_position = collision_shape.position
@onready var collision_radius = collision_shape.shape.radius
@onready var shapecast = $ShapeCast3D
# RayCasts
@onready var raycast_lookat = camera.get_node("RayCast3D")
@onready var raycast_jumptarget = $Visuals/RayCast3D_JumpTarget
@onready var raycast_top = $Visuals/RayCast3D_InFrontPlayer_Top
@onready var raycast_high = raycast_top.get_node("../RayCast3D_InFrontPlayer_High")
@onready var raycast_middle = raycast_top.get_node("../RayCast3D_InFrontPlayer_Middle")
@onready var raycast_use = raycast_top.get_node("../RayCast3D_InFrontPlayer_Use")
@onready var raycast_low = raycast_top.get_node("../RayCast3D_InFrontPlayer_Low")
@onready var raycast_below = raycast_top.get_node("../RayCast3D_BelowPlayer")
# Visuals and Skeleton
@onready var visuals = $Visuals
@onready var visuals_offset = visuals.position
@onready var visuals_aux_scene = visuals.get_node("AuxScene")
@onready var visuals_aux_scene_position = visuals_aux_scene.position
@onready var player_skeleton = visuals_aux_scene.get_node("GeneralSkeleton")
@onready var bone_attachement_left_foot = player_skeleton.get_node("BoneAttachment3D_LeftFoot")
@onready var bone_attachement_right_foot = player_skeleton.get_node("BoneAttachment3D_RightFoot")
@onready var bone_attachement_left_hand = player_skeleton.get_node("BoneAttachment3D_LeftHand")
@onready var bone_attachement_right_hand = player_skeleton.get_node("BoneAttachment3D_RightHand")
@onready var look_at_modifier = player_skeleton.get_node("LookAtModifier3D")
# Initial Values
@onready var initial_position = position


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Uncomment the next line if using GodotSteam
	#camera.current = is_multiplayer_authority()

	# Set the canvas layer behind all other Control nodes
	$Controls.layer = -1

	# Start "standing"
	$States/Standing.start()


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
func _physics_process(delta) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	
	# Check if the game is not paused
	if !game_paused:
		# Apply gravity (but not if climbing, driving, hanging, swimming, or noclip)
		if !is_climbing and !is_driving and !is_hanging:
			# Check if the player is "swimming" or noclip mode is enabled
			if is_swimming or enable_noclip:
				# Ignore the gravity
				velocity.y = 0.0

			# The player must not be "swimming" or using noclip mode
			else:
				# Scale the gravity based on the player's size
				var gravity_scaled = gravity * scale.y

				# Add the gravity
				velocity.y -= gravity_scaled * delta
		# Check if no animation is playing
		if !animation_player.is_playing():
			# Flag the animation player no longer locked
			is_animation_locked = false

			# Reset player state
			is_kicking_left = false
			is_kicking_right = false
			is_punching_left = false
			is_punching_right = false

		# Check if player is not hanging or climbing (these states handle their own movement)
		if !is_hanging and !is_climbing:
			# Handle player movement (input-based movement)
			update_velocity()

		# Move player (physics movement)
		move_player(delta)
	else:
		# When paused, stop all movement by zeroing velocity
		velocity = Vector3.ZERO


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !game_paused:
		# Check if the noclip mode is enabled
		if enable_noclip:
			# [Re]Set player's movement speed
			speed_current = speed_flying_fast
			# [crouch] button _pressed_
			if Input.is_action_pressed("button_3"):
				global_position = global_position - Vector3(0, delta * 10, 0)
			# [jump] button _pressed_
			if Input.is_action_pressed("button_0"):
				global_position = global_position + Vector3(0, delta * 10, 0)


## Check if the kick hits anything.
func check_kick_collision() -> void:
	# Check if the RayCast3D is colliding with something
	if raycast_low.is_colliding():
		# Get the object the RayCast is colliding with
		var collider = raycast_low.get_collider()

		# Get the position of the current collision
		var collision_position = raycast_low.get_collision_point()

		# Store collision info for delayed force application
		var stored_collider = collider
		var stored_collision_position = collision_position

		# Wait 0.4 seconds for animation to play before applying force
		await get_tree().create_timer(0.4).timeout

		# Apply force to RigidBody3D and SoftBody3D objects after delay
		if stored_collider is RigidBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_kicking_sprinting if is_sprinting else force_kicking

			# Get the appropriate foot bone position for force application at the time of impact
			var bone_position = global_position  # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_FOOT if is_kicking_left else BONE_NAME_RIGHT_FOOT
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)

			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 2.0)  # Minimum 2.0 for strong kicks even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier

			# Apply the force to the object
			stored_collider.apply_central_impulse(impulse)

		elif stored_collider is SoftBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_kicking_sprinting if is_sprinting else force_kicking

			# Get the appropriate foot bone position for force application at the time of impact
			var bone_position = global_position  # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_FOOT if is_kicking_left else BONE_NAME_RIGHT_FOOT
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)

			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 2.0)  # Minimum 2.0 for strong kicks even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier

			# Apply the force to the SoftBody3D
			stored_collider.apply_central_impulse(impulse)

		# Check if the collider is a CharacterBody3D (apply hit animation immediately)
		if stored_collider is CharacterBody3D:
			# Check if kicking left
			if is_kicking_left:
				# Check if the collider has the appropriate function
				if stored_collider.has_method("animate_hit_low_left"):
					# Play the appropriate hit animation
					stored_collider.call("animate_hit_low_left")

			# Must be kicking right
			else:
				# Check if the collider has the appropriate function
				if stored_collider.has_method("animate_hit_low_right"):
					# Play the appropriate hit animation
					stored_collider.call("animate_hit_low_right")

		# Check if controller vibration is enabled
		if enable_vibration:
			# Vibrate the controller
			Input.start_joy_vibration(0, 0.0, 1.0, 0.1)

		# Additional delay for animation reset (0.2 more seconds, total 0.6s)
		await get_tree().create_timer(0.2).timeout

		# Flag the animation player no longer locked
		is_animation_locked = false

		# Reset action flag(s)
		is_kicking_left = false
		is_kicking_right = false


## Checks if the thrown punch hits anything.
func check_punch_collision() -> void:
	# Check if the RayCast3D is colliding with something
	if raycast_middle.is_colliding():
		# Get the object the RayCast is colliding with
		var collider = raycast_middle.get_collider()

		# Get the position of the current collision
		var collision_position = raycast_middle.get_collision_point()

		# Store collision info for delayed force application
		var stored_collider = collider
		var stored_collision_position = collision_position

		# Wait 0.2 seconds for animation to play before applying force
		await get_tree().create_timer(0.2).timeout

		# Apply force to RigidBody3D and SoftBody3D objects after delay
		if stored_collider is RigidBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_punching_sprinting if is_sprinting else force_punching

			# Get the appropriate hand bone position for force application at the time of impact
			var bone_position = global_position  # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_HAND if is_punching_left else BONE_NAME_RIGHT_HAND
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)

			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 1.5)  # Minimum 1.5 for strong punches even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier

			# Apply the force to the object
			stored_collider.apply_central_impulse(impulse)

		elif stored_collider is SoftBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_punching_sprinting if is_sprinting else force_punching

			# Get the appropriate hand bone position for force application at the time of impact
			var bone_position = global_position  # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_HAND if is_punching_left else BONE_NAME_RIGHT_HAND
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)

			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 1.5)  # Minimum 1.5 for strong punches even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier

			# Apply the force to the SoftBody3D
			stored_collider.apply_central_impulse(impulse)

		# Check if the collider is a CharacterBody3D (apply hit animation immediately)
		if stored_collider is CharacterBody3D:
			# Check if punching left
			if is_punching_left:
				# Check if the collider has the appropriate function
				if stored_collider.has_method("animate_hit_high_left"):
					# Play the appropriate hit animation
					stored_collider.call("animate_hit_high_left")

			# Must be punching right
			else:
				# Check if the collider has the appropriate function
				if stored_collider.has_method("animate_hit_high_right"):
					# Play the appropriate hit animation
					stored_collider.call("animate_hit_high_right")

		# Check if controller vibration is enabled
		if enable_vibration:
			# Vibrate the controller
			Input.start_joy_vibration(0, 1.0, 0.0, 0.1)

		# Additional delay for animation reset (0.1 more seconds, total 0.3s)
		await get_tree().create_timer(0.1).timeout

		# Flag the animation player no longer locked
		is_animation_locked = false

		# Reset action flag(s)
		is_punching_left = false
		is_punching_right = false


## Moves the player based on velocity and shapecast collision.
func move_player(delta: float) -> void:
	# Set the shapecast position to the player's potential new position
	shapecast.global_position.x = global_position.x + velocity.x * delta
	shapecast.global_position.z = global_position.z + velocity.z * delta

	# Check if the player is grounded
	if is_on_floor():
		shapecast.target_position.y = -0.5
	else:
		shapecast.target_position.y = 0.55

	# Create a new physics query object used for checking collisions in 3D space
	var query = PhysicsShapeQueryParameters3D.new()

	# Tell the physics query to ignore the current object (self) when checking for collisions
	query.exclude = [self]

	# Set the collision shape to match a "shapecast" object's shape
	query.shape = shapecast.shape

	# Set the position and rotation (transform) to match where the shapecast is in global space
	query.transform = shapecast.global_transform

	# Get the current 3D world, give direct access to the physics engine, and check if the shape intersects with anything (limited to 1 result)
	var result = get_world_3d().direct_space_state.intersect_shape(query, 1)

	# Check if no collisions were detected
	if !result:
		# Force the shapecast to update its state
		shapecast.force_shapecast_update()

	# Check if the shapecast is colliding, the player is moving down (or not at all), no direct collision was found, and the angle of the slope isn't too great
	if shapecast.is_colliding() and velocity.y <= 0.0 and !result and shapecast.get_collision_normal(0).angle_to(Vector3.UP) < floor_max_angle:
		# Set the character's Y position to match the collision point (likely the ground)
		global_position.y = shapecast.get_collision_point(0).y

		# Stop vertical movement by zeroing the Y velocity
		velocity.y = 0.0

	# Handle noclip mode
	if enable_noclip:
		velocity.y = 0.0

	# Moves the body based on velocity.
	move_and_slide()


## Reparent the held item to the root of the scene tree.
func reparent_held_item() -> void:
	# Check if the player is holding an item
	if is_holding_onto != null:
		# Remove the item from the player
		visuals.get_node("HeldItemMount").remove_child(is_holding_onto)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(is_holding_onto)
		# Stop holding the item
		is_holding_onto = null
		is_holding_fishing_rod = false
		is_holding_rifle = false
		is_holding_tool = false


## Toggles the noclip mode.
func toggle_noclip() -> void:
	enable_noclip = !enable_noclip
	collision_shape.disabled = enable_noclip


## Update the player's velocity based on input and status.
func update_velocity() -> void:
	# Get an input vector by specifying four actions for the positive and negative X and Y axes
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Create a normalized 3D direction vector from the 2D input
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Calculate the input magnitude (intensity of the left-analog stick)
	var input_magnitude = input_dir.length()

	# Set the player's movement speed based on the input magnitude
	if speed_current == 0.0 and input_magnitude != 0.0:
		#speed_current = input_magnitude * speed_running 
		speed_current = speed_running # ToDo: Fine tune walking with the left-analog stick

	# Scale the speed based on the player's size
	var speed_current_scaled = speed_current * scale.x

	# Check for directional movement
	if direction:
		# Check if the animation player is unlocked
		if !is_animation_locked:
			# Check if the player is not in "third person" perspective and not climbing/hanging
			if perspective == 0 and !is_climbing and !is_hanging:
				# Update the camera to look in the direction based on player input
				visuals.look_at(position + direction)

			# Check if movement along the x-axis is locked
			if lock_movement_x:
				# Update [virtual] horizontal velocity
				virtual_velocity.x = direction.x * speed_current_scaled

			# The x-axis movement not locked
			else:
				# Update horizontal velocity
				velocity.x = direction.x * speed_current_scaled

			# Check if movement along the z-axis is locked
			if lock_movement_y:
				# Update vertical velocity
				virtual_velocity.z = direction.z * speed_current_scaled

			# The y-axis movement not locked
			else:
				# Update vertical velocity
				velocity.z = direction.z * speed_current_scaled

	# No movement detected
	else:
		# Check if the player is skateboarding and grounded
		if is_skateboarding and is_on_floor():
			# Set the friction to the skateboarding friction
			var friction_current = friction_skateboarding

			# [crouch] action _pressed_
			if is_crouching:
				# Slow down the player, more than usual
				friction_current = friction_current * 10

			# Apply gradual deceleration when skating
			velocity.x = move_toward(velocity.x, 0, speed_current_scaled * friction_current)
			velocity.z = move_toward(velocity.z, 0, speed_current_scaled * friction_current)

		# Check if the player is skateboarding but in the air (preserve momentum)
		elif is_skateboarding and !is_on_floor():
			# Preserve horizontal momentum while skateboarding in the air
			# Don't modify velocity.x and velocity.z to maintain jump momentum
			pass

		# The player is not skateboarding (on the ground)
		else:
			# Update horizontal velocity
			velocity.x = move_toward(velocity.x, 0, speed_current_scaled)

			# Update vertical velocity
			velocity.z = move_toward(velocity.z, 0, speed_current_scaled)

			# Update [virtual] velocity
			virtual_velocity = Vector3.ZERO

	# Check for collisions with RigidBody3D objects during movement
	handle_rigidbody_collisions()


## Handles collision with RigidBody3D and SoftBody3D objects and applies pushing force
func handle_rigidbody_collisions() -> void:
	# Only check actual physical collisions from move_and_slide() with the CharacterBody3D's CollisionShape3D
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Handle RigidBody3D collisions
		if collider is RigidBody3D:
			# Calculate push force based on player velocity and movement
			var push_force = force_pushing_sprinting if is_sprinting else force_pushing
			var push_direction = collision.get_normal() * -1.0  # Opposite of collision normal
			var velocity_factor = min(velocity.length(), 5.0)  # Cap velocity factor to prevent excessive force
			var impulse = push_direction * push_force * velocity_factor * force_pushing_multiplier

			# Apply the impulse to the RigidBody3D
			collider.apply_central_impulse(impulse)

		# Handle SoftBody3D collisions
		elif collider is SoftBody3D:
			# Calculate push force based on player velocity and movement
			var push_force = force_pushing_sprinting if is_sprinting else force_pushing
			var push_direction = collision.get_normal() * -1.0  # Opposite of collision normal
			var velocity_factor = min(velocity.length(), 5.0)  # Cap velocity factor to prevent excessive force
			var impulse = push_direction * push_force * velocity_factor * force_pushing_multiplier

			# Apply the impulse to the SoftBody3D
			collider.apply_central_impulse(impulse)
