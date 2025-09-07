extends CharacterBody3D

const BONE_NAME_HEAD = "Head"
const BONE_NAME_LEFT_HAND = "LeftHand"
const BONE_NAME_RIGHT_HAND = "RightIndexProximal" # Right hand index finger proximal bone
const BONE_NAME_LEFT_FOOT = "LeftFoot"
const BONE_NAME_RIGHT_FOOT = "RightFoot"
const STATES = preload("uid://dodroqwgmf811")

# Note: `@export` variables are available for editing in the property editor.
@export var current_state: STATES.State = STATES.State.STANDING ## The current state of the player.
@export var game_paused: bool = false ## Is the game paused?
@export_group("Toggle Features")
@export var enable_chat: bool = true ## Enable the chat window
@export var enable_emotes: bool = true ## Enable emotes
@export var enable_climbing: bool = true ## Enable climbing
@export var enable_crouching: bool = true ## Enable crouching
@export var enable_double_jump: bool = false ## Enable double jump
@export var enable_flying: bool = false ## Enable flying
@export var enable_jumping: bool = true ## Enable jumping
@export var enable_kicking: bool = true ## Enable kicking
@export var enable_noclip: bool = false ## Enable noclip
@export var enable_paragliding: bool = true ## Enable paragliding
@export var enable_punching: bool = true ## Enable punching
@export var enable_rolling: bool = true ## Enable rolling
@export var enable_sliding: bool = true ## Enable sliding
@export var enable_sprinting: bool = true ## Enable sprinting
@export var enable_vibration: bool = false ## Enable controller vibration
@export_group("Camera Settings")
@export var lock_camera: bool = false ## Lock the camera
@export var lock_perspective: bool = false ## Lock the camera perspective
@export var perspective: int = 0 ## 0 = Third Person, 1 = First Person
@export_group("Movement Settings")
@export var friction_skateboarding: float = 0.01 ## Friction while skateboarding
@export var jump_velocity: float = 4.5 ## Jump velocity
@export var lock_movement_x: bool = false ## Lock movement on the X axis
@export var lock_movement_y: bool = false ## Lock movement on the Y axis
@export var rotation_smoothing: float = 30.0 ## Speed of rotation smoothing interpolation
@export var speed_climbing: float = 0.5 ## Speed while climbing
@export var speed_crawling: float = 0.75 ## Speed while crawling
@export var speed_current: float = 3.0 ## Current speed
@export var speed_flying: float = 5.0 ## Speed while flying
@export var speed_flying_fast: float = 10.0 ## Speed while flying fast
@export var speed_hanging: float = 0.25 ## Speed while hanging (shimmying)
@export var speed_rolling: float = 2.0 ## Speed while rolling
@export var speed_running: float = 3.5 ## Speed while running
@export var speed_sprinting: float = 5.0 ## Speed while sprinting
@export var speed_swimming: float = 3.0 ## Speed while swimming
@export var speed_walking: float = 1.0 ## Speed while walking
@export_group("Physics Settings")
@export var force_kicking: float = 2.0 ## Force applied when kicking
@export var force_kicking_sprinting: float = 3.0 ## Force applied when kicking while sprinting
@export var force_punching: float = 1.0 ## Force applied when punching
@export var force_punching_sprinting: float = 1.5 ## Force applied when punching while sprinting
@export var force_pushing: float = 0.2 ## Force applied when pushing
@export var force_pushing_sprinting: float = 0.4 ## Force applied when pushing while sprinting
@export var force_pushing_multiplier: float = 1.0 ## Global multiplier for all pushing/hitting forces
@export var throw_force: float = 3.5 ## Force applied when throwing

# State machine variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") ## Default gravity value
var is_aiming: bool = false ## Is the player aiming?
var is_animation_locked: bool = false ## Is the animation player locked?
var is_braced: bool = false ## Is the player braced against a wall when hanging?
var is_blocking_left: bool = false ## Is the player blocking with their left arm?
var is_blocking_right: bool = false ## Is the player blocking with their right arm?
var is_casting: bool = false ## Is the player casting a fishing line?
var is_climbing: bool = false ## Is the player climbing?
var is_crawling: bool = false ## Is the player crawling?
var is_crouching: bool = false ## Is the player crouching?
var is_double_jumping: bool = false ## Is the player double jumping?
var is_driving: bool = false ## Is the player driving?
var is_driving_in ## The Node the player is driving in.
var is_falling: bool = false ## Is the player falling?
var is_firing: bool = false ## Is the player firing a weapon?
var is_flying: bool = false ## Is the player flying?
var is_hanging: bool = false ## Is the player hanging from a ledge?
var is_holding: bool = false ## Is the player holding an object in front of them?
var is_holding_fishing_rod: bool = false ## Is the player holding a fishing rod?
var is_holding_rifle: bool = false ## Is the player holding a rifle?
var is_holding_tool: bool = false ## Is the player holding a tool?
var is_jumping: bool = false ## Is the player jumping?
var is_kicking_left: bool = false ## Is the player kicking with the left foot?
var is_kicking_right: bool = false ## Is the player kicking with the right foot?
var is_paragliding: bool = false ## Is the player paragliding?
var is_punching_left: bool = false ## Is the player punching with the left hand?
var is_punching_right: bool = false ## Is the player punching with the right hand?
var is_pushing: bool = false ## Is the player pushing something?
var is_reeling: bool = false ## Is the player reeling in a fishing line?
var is_rotating_object: bool = false ## Is the player rotating an object being held in front of them?
var is_running: bool = false ## Is the player running?
var is_sliding: bool = false ## Is the player sliding?
var is_shimmying: bool = false ## Is the player shimmying along a ledge?
var is_skateboarding: bool = false ## Is the player skateboarding?
var is_sprinting: bool = false ## Is the player sprinting?
var is_standing: bool = false ## Is the player standing?
var is_swinging_left: bool = false ## Is the player swinging with the left arm?
var is_swinging_right: bool = false ## Is the player swinging with the right arm?
var is_swimming_in ## The Node the player is swimming in
var is_swimming: bool = false ## Is the player swimming?
var is_sitting: bool = false ## Is the player sitting?
var is_rolling: bool = false ## Is the player rolling?
var is_using: bool = false ## Is the player using an object?
var is_walking: bool = false ## Is the player walking?
var virtual_velocity: Vector3 = Vector3.ZERO ## The velocity of the player if they moved, to be used when movement is locked.

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
@onready var emotes_menu = camera.get_node("Emotes")
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
@onready var foot_mount = visuals.get_node("FootMount")
@onready var head_mount = visuals.get_node("HeadMount")
@onready var visuals_offset = visuals.position
@onready var visuals_aux_scene = visuals.get_node("AuxScene")
@onready var visuals_aux_scene_position = visuals_aux_scene.position
@onready var player_skeleton = visuals_aux_scene.get_node("GeneralSkeleton")
@onready var bone_attachment_left_foot = player_skeleton.get_node("BoneAttachment3D_LeftFoot")
@onready var bone_attachment_right_foot = player_skeleton.get_node("BoneAttachment3D_RightFoot")
@onready var bone_attachment_left_hand = player_skeleton.get_node("BoneAttachment3D_LeftHand")
@onready var bone_attachment_right_hand = player_skeleton.get_node("BoneAttachment3D_RightHand")
@onready var look_at_modifier = player_skeleton.get_node("LookAtModifier3D")
@onready var physical_bone_simulator = player_skeleton.get_node_or_null("PhysicalBoneSimulator3D")
# Initial Values
@onready var initial_aux_scene_transform: Transform3D = visuals_aux_scene.transform
@onready var initial_position = position ## used for "Return Home" in START menu
@onready var initial_shapecast_target_position = shapecast.target_position


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the canvas layer behind all other Control nodes
	$Controls.layer = -1
	# Start "standing"
	$States/Standing.start()
	# Add sitting state node if not present
	if not $States.has_node("Sitting"):
		var sitting_node = load("res://addons/3d_player_controller/states/sitting.gd").new()
		sitting_node.name = "Sitting"
		$States.add_child(sitting_node)


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
func _physics_process(delta) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Don't process physics if in ragdoll state - let the physics bones handle everything
	if current_state == STATES.State.RAGDOLL:
		return
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
		is_swinging_left = false
		is_swinging_right = false
	# Check if player is not hanging or climbing (these states handle their own movement)
	# Also check if animation is not locked (prevents movement during transitions)
	if !is_hanging and !is_climbing and !is_animation_locked:
		# Handle player movement (input-based movement when not paused, gradual stopping when paused)
		update_velocity()
	# Move player (physics movement)
	move_player(delta)
	# Check if the player is not driving
	if !is_driving:
		# Update AuxScene position if top_level is true
		update_aux_scene_transform(delta)


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !game_paused:
		# Check if the noclip mode is enabled
		if enable_noclip:
			# [Re]Set player's movement speed
			speed_current = speed_flying_fast
			# Ⓨ/[Ctrl] _pressed_
			if Input.is_action_pressed("button_3"):
				global_position = global_position - Vector3(0, delta * 10, 0)
			# Ⓐ/[Space] button _pressed_
			if Input.is_action_pressed("button_0"):
				global_position = global_position + Vector3(0, delta * 10, 0)


@rpc("any_peer", "call_local")
func animate_hit_low_left() -> void:
	# Lock the player animation
	is_animation_locked = true
	# Play the low left hit animation
	animation_player.play("Reaction_Low_Left" + "/mixamo_com")


@rpc("any_peer", "call_local")
func animate_hit_low_right() -> void:
	# Lock the player animation
	is_animation_locked = true
	# Play the low right hit animation
	animation_player.play("Reaction_Low_Right" + "/mixamo_com")


@rpc("any_peer", "call_local")
func animate_hit_high_left() -> void:
	# Lock the player animation
	is_animation_locked = true
	# Play the high left hit animation
	animation_player.play("Reaction_High_Left" + "/mixamo_com")


@rpc("any_peer", "call_local")
func animate_hit_high_right() -> void:
	# Lock the player animation
	is_animation_locked = true
	# Play the high right hit animation
	animation_player.play("Reaction_High_Right" + "/mixamo_com")


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
		# Apply force to RigidBody3D objects after delay
		if stored_collider is RigidBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_kicking_sprinting if is_sprinting else force_kicking
			# Get the appropriate foot bone position for force application at the time of impact
			var bone_position = global_position # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_FOOT if is_kicking_left else BONE_NAME_RIGHT_FOOT
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)
			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 2.0) # Minimum 2.0 for strong kicks even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier
			# Apply the force to the object
			stored_collider.apply_central_impulse(impulse)
		# Apply force to SoftBody3D objects after delay
		elif stored_collider is SoftBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_kicking_sprinting if is_sprinting else force_kicking
			# Get the appropriate foot bone position for force application at the time of impact
			var bone_position = global_position # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_FOOT if is_kicking_left else BONE_NAME_RIGHT_FOOT
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)
			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 2.0) # Minimum 2.0 for strong kicks even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier
			# Apply the force to the SoftBody3D
			stored_collider.apply_central_impulse(impulse)
		# Check if kicking left
		if is_kicking_left:
			# Check if the collider has the appropriate function
			if stored_collider.has_method("animate_hit_low_left"):
				# Play the appropriate hit animation
				stored_collider.rpc("animate_hit_low_left")
		# Must be kicking right
		else:
			# Check if the collider has the appropriate function
			if stored_collider.has_method("animate_hit_low_right"):
				# Play the appropriate hit animation
				stored_collider.rpc("animate_hit_low_right")
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
		# Apply force to RigidBody3D objects after delay
		if stored_collider is RigidBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_punching_sprinting if is_sprinting else force_punching
			# Get the appropriate hand bone position for force application at the time of impact
			var bone_position = global_position # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_HAND if is_punching_left else BONE_NAME_RIGHT_HAND
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)
			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 1.5) # Minimum 1.5 for strong punches even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier
			# Apply the force to the object
			stored_collider.apply_central_impulse(impulse)
		# Apply force to SoftBody3D objects after delay
		elif stored_collider is SoftBody3D:
			# Define the base force to apply to the collided object
			var base_force = force_punching_sprinting if is_sprinting else force_punching
			# Get the appropriate hand bone position for force application at the time of impact
			var bone_position = global_position # Fallback to player position
			if player_skeleton:
				var bone_name = BONE_NAME_LEFT_HAND if is_punching_left else BONE_NAME_RIGHT_HAND
				var bone_idx = player_skeleton.find_bone(bone_name)
				if bone_idx != -1:
					# Get the current global position of the bone
					bone_position = player_skeleton.to_global(player_skeleton.get_bone_global_pose(bone_idx).origin)
			# Calculate impulse direction from current bone position to stored collision point
			var impulse_direction = (stored_collision_position - bone_position).normalized()
			# Add velocity factor similar to handle_rigidbody_collisions for more powerful impacts
			var velocity_factor = max(min(velocity.length(), 5.0), 1.5) # Minimum 1.5 for strong punches even when stationary
			var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier
			# Apply the force to the SoftBody3D
			stored_collider.apply_central_impulse(impulse)
		# Check if punching left
		if is_punching_left:
			# Check if the collider has the appropriate function
			if stored_collider.has_method("animate_hit_high_left"):
				# Play the appropriate hit animation
				stored_collider.rpc("animate_hit_high_left")
		# Must be punching right
		else:
			# Check if the collider has the appropriate function
			if stored_collider.has_method("animate_hit_high_right"):
				# Play the appropriate hit animation
				stored_collider.rpc("animate_hit_high_right")
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


## Checks if the tool hits anything when swung.
func check_tool_collision() -> void:
	# Check if the player is holding a tool and swinging
	if is_holding_tool and (is_swinging_left or is_swinging_right):
		# Get the tool from the right hand bone attachment
		if bone_attachment_right_hand.get_child_count() > 0:
			var tool = bone_attachment_right_hand.get_child(0)
			# Check if the tool has the required Area3D structure
			if tool.has_node("Visuals/Area3D"):
				var tool_area = tool.get_node("Visuals/Area3D")
				# Wait 0.3 seconds for the swing animation to position the tool properly
				await get_tree().create_timer(0.3).timeout
				# Continuously check for collisions until one is detected or swing ends
				var collision_detected = false
				var max_check_time = 2.0 # Maximum time to check for collisions (safety limit)
				var check_start_time = Time.get_time_dict_from_system()
				# Loop to check for collisions while swinging
				while not collision_detected and (is_swinging_left or is_swinging_right):
					# Check elapsed time to prevent infinite loops
					var current_time = Time.get_time_dict_from_system()
					var elapsed = (current_time.hour * 3600 + current_time.minute * 60 + current_time.second) - \
								 (check_start_time.hour * 3600 + check_start_time.minute * 60 + check_start_time.second)
					# If elapsed time exceeds max_check_time, break the loop
					if elapsed > max_check_time:
						break
					# Get all bodies currently overlapping with the tool's Area3D
					var overlapping_bodies = tool_area.get_overlapping_bodies()
					# Process each overlapping body
					for body in overlapping_bodies:
						# Skip if it's the player themselves
						if body == self:
							continue
						# Get the collision shape to find the contact point
						if tool.has_node("Visuals/Area3D/CollisionShape3D"):
							var collision_shape = tool.get_node("Visuals/Area3D/CollisionShape3D")
							var collision_position = collision_shape.global_position
							# base_state.draw_debug_sphere(collision_position, Color.RED) # Uncomment for debugging
							collision_detected = true
							# Store collision info for immediate force application
							var stored_body = body
							var stored_collision_position = collision_position
							# Apply force to RigidBody3D objects immediately
							if stored_body is RigidBody3D:
								# Define the base force to apply (stronger than punches/kicks since it's a tool)
								var base_force = 4.0 # Higher base force for tool swinging
								if is_sprinting:
									base_force *= 1.5 # Increase force when sprinting
								# Get the tool's position for force direction calculation
								var tool_position = tool.global_position
								# Calculate impulse direction from tool position to collision point
								var impulse_direction = (stored_collision_position - tool_position).normalized()
								# Add velocity factor for more powerful impacts based on player movement
								var velocity_factor = max(min(velocity.length(), 6.0), 2.5) # Higher minimum for tool impacts
								var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier
								# Apply the force to the object
								stored_body.apply_central_impulse(impulse)
							# Apply force to SoftBody3D objects immediately
							elif stored_body is SoftBody3D:
								# Define the base force to apply (stronger than punches/kicks since it's a tool)
								var base_force = 4.0 # Higher base force for tool swinging
								if is_sprinting:
									base_force *= 1.5 # Increase force when sprinting
								# Get the tool's position for force direction calculation
								var tool_position = tool.global_position
								# Calculate impulse direction from tool position to collision point
								var impulse_direction = (stored_collision_position - tool_position).normalized()
								# Add velocity factor for more powerful impacts based on player movement
								var velocity_factor = max(min(velocity.length(), 6.0), 2.5) # Higher minimum for tool impacts
								var impulse = impulse_direction * base_force * velocity_factor * force_pushing_multiplier
								# Apply the force to the SoftBody3D
								stored_body.apply_central_impulse(impulse)
							# Check if swinging left
							if is_swinging_left:
								# Check if the body has the appropriate function
								if stored_body.has_method("animate_hit_high_left"):
									# Play the appropriate hit animation
									stored_body.rpc("animate_hit_high_left")
							# Must be swinging right
							else:
								# Check if the body has the appropriate function
								if stored_body.has_method("animate_hit_high_right"):
									# Play the appropriate hit animation
									stored_body.rpc("animate_hit_high_right")
							# Check if controller vibration is enabled
							if enable_vibration:
								# Vibrate the controller (stronger vibration for tool impact)
								Input.start_joy_vibration(0, 0.8, 0.8, 0.2)
							# Break after processing the first collision to avoid multiple hits
							break
					# Wait a frame before checking again to avoid blocking the main thread
					await get_tree().process_frame
				# If collision was detected, wait for animation to finish before resetting flags
				if collision_detected:
					# Wait for animation to complete before resetting flags
					await get_tree().create_timer(0.5).timeout
					# Flag the animation player no longer locked
					is_animation_locked = false
					# Reset action flag(s)
					is_swinging_left = false
					is_swinging_right = false


## Getter for the player's username.
func get_username() -> String:
	var username = ""
	if username.is_empty():
		username = OS.get_environment("USERNAME")
	if username.is_empty():
		username = OS.get_environment("USER")
	return username


## Moves the player based on velocity and shapecast collision.
func move_player(delta: float) -> void:
	# Don't move the player if in ragdoll state - let physics bones handle movement
	if current_state == STATES.State.RAGDOLL:
		return
	# Set the shapecast position to the player's potential new position
	shapecast.global_position.x = global_position.x + velocity.x * delta
	shapecast.global_position.z = global_position.z + velocity.z * delta
	# Check if the player is grounded
	if is_on_floor():
		# Adjust the position to be at the player's feet
		shapecast.target_position.y = initial_shapecast_target_position.y
	else:
		# Move the shapecast up to avoid most collisions
		shapecast.target_position.y = 0.0
	# Create a new physics query object used for checking collisions in 3D space
	var query = PhysicsShapeQueryParameters3D.new()
	# Tell the physics query to ignore _this_ node when checking for collisions
	query.exclude = [self]
	# Set the collision shape to match the "shapecast" object's shape
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
	if !is_driving:
		move_and_slide()


## Reparent the held item to the root of the scene tree.
func reparent_held_item() -> void:
	# Reset holding state
	is_holding = false
	# Reparent any foot items
	reparent_equipped_foot_items()
	# Reparent any hand items
	reparent_equipped_hand_items()
	# Reparent any head items
	reparent_equipped_head_items()


## Reparents all items attached to the left and right foot bones to the main scene.
func reparent_equipped_foot_items() -> void:
	# Reparent the under foot items
	for child in foot_mount.get_children():
		# Remove the player from the item
		if "player" in child:
			child.player = null
		# Remove the item from the player
		foot_mount.remove_child(child)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(child)
	# Reparent the left foot items
	for child in bone_attachment_left_foot.get_children():
		# Remove the player from the item
		if "player" in child:
			child.player = null
		# Remove the item from the player
		bone_attachment_left_foot.remove_child(child)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(child)
	# Reparent the right foot items
	for child in bone_attachment_right_foot.get_children():
		# Remove the player from the item
		if "player" in child:
			child.player = null
		# Remove the item from the player
		bone_attachment_right_foot.remove_child(child)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(child)


## Reparents all items attached to the left and right hand bones to the main scene.
func reparent_equipped_hand_items() -> void:
	# Reparent the left hand items
	for child in bone_attachment_left_hand.get_children():
		# Remove the player from the item
		if "player" in child:
			child.player = null
		# Remove the item from the player
		bone_attachment_left_hand.remove_child(child)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(child)
	# Reparent the right hand items
	for child in bone_attachment_right_hand.get_children():
		# Remove the player from the item
		if "player" in child:
			child.player = null
		# Remove the item from the player
		bone_attachment_right_hand.remove_child(child)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(child)
	# Reset the flags for holding items
	is_holding_fishing_rod = false
	is_holding_rifle = false
	is_holding_tool = false


## Reparent the overhead item to the root of the scene tree.
func reparent_equipped_head_items() -> void:
	# Reparent the overhead items
	for child in head_mount.get_children():
		# Remove the player from the item
		if "player" in child:
			child.player = null
		# Remove the item from the player
		head_mount.remove_child(child)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(child)


## Updates the AuxScene transform to follow the player when top_level is true
func update_aux_scene_transform(delta: float) -> void:
	# Check if AuxScene exists
	if visuals_aux_scene != null:
		# Check if AuxScene has top_level enabled
		if visuals_aux_scene.top_level != null:
			# Calculate target rotation
			var target_rotation = Vector3(
				visuals.global_rotation.x,
				visuals.global_rotation.y + initial_aux_scene_transform.basis.get_euler().y,
				visuals.global_rotation.z
			)
			# Convert current and target rotations to quaternions for smooth interpolation
			var current_quat = Quaternion.from_euler(visuals_aux_scene.rotation)
			var target_quat = Quaternion.from_euler(target_rotation)
			# Slerp the rotation with a smooth interpolation factor
			var smooth_quat = current_quat.slerp(target_quat, rotation_smoothing * delta)
			# Apply the smoothed rotation
			visuals_aux_scene.rotation = smooth_quat.get_euler()

			# Calculate the target position based on player and visuals transforms
			var target_global_position = global_position + (global_transform.basis * visuals_offset)
			# Apply smoothing (if enabled)
			if raycast_below.is_colliding() and velocity != Vector3.ZERO and !is_climbing and !is_driving and !is_falling and !is_flying and !is_hanging and !is_jumping and !is_shimmying:
				# Get the current position of the AuxScene
				var current_position = visuals_aux_scene.global_position
				# Smooth only the y-axis position
				var smooth_y = lerp(current_position.y, target_global_position.y, 10 * delta)
				# Set the new position based on lerp value
				visuals_aux_scene.global_position = Vector3(target_global_position.x, smooth_y, target_global_position.z)
			# Smoothing must not be enabled
			else:
				# No smoothing, directly set position
				visuals_aux_scene.global_position = target_global_position


## Toggles the noclip mode.
func toggle_noclip() -> void:
	enable_noclip = !enable_noclip
	collision_shape.disabled = enable_noclip


## Update the player's velocity based on input and status.
func update_velocity() -> void:
	# If the game is paused, gradually stop horizontal movement but preserve vertical physics
	if game_paused:
		# Only stop horizontal movement if the player is on the ground
		# This preserves jump momentum and allows natural jump arcs to complete
		if is_on_floor():
			# Scale the speed based on the player's size for consistent stopping
			var speed_current_scaled = speed_current * scale.x
			# Gradually reduce horizontal velocity to zero
			velocity.x = move_toward(velocity.x, 0, speed_current_scaled)
			velocity.z = move_toward(velocity.z, 0, speed_current_scaled)
		# Update [virtual] velocity to zero as well
		virtual_velocity = Vector3.ZERO
		# Don't process any input when paused
		return
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
			# Ⓨ/[Ctrl] action _pressed_
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
			var push_direction = collision.get_normal() * -1.0 # Opposite of collision normal
			var velocity_factor = min(velocity.length(), 5.0) # Cap velocity factor to prevent excessive force
			var impulse = push_direction * push_force * velocity_factor * force_pushing_multiplier
			# Apply the impulse to the RigidBody3D
			collider.apply_central_impulse(impulse)
		# Handle SoftBody3D collisions
		elif collider is SoftBody3D:
			# Calculate push force based on player velocity and movement
			var push_force = force_pushing_sprinting if is_sprinting else force_pushing
			var push_direction = collision.get_normal() * -1.0 # Opposite of collision normal
			var velocity_factor = min(velocity.length(), 5.0) # Cap velocity factor to prevent excessive force
			var impulse = push_direction * push_force * velocity_factor * force_pushing_multiplier
			# Apply the impulse to the SoftBody3D
			collider.apply_central_impulse(impulse)
