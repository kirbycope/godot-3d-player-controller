extends CharacterBody3D

# Change the animation names to those in character's animation player
const crouching_idle = "crouching_idle"
const crawling_in_place = "crawling_in_place"
const idle = "idle"
const falling_idle = "falling_idle"
const flying = "flying"
const flying_fast = "flying_fast"
const hanging_idle = "hanging_idle"
const kicking_low_left = "kicking_low_left"
const kicking_low_right = "kicking_low_right"
const jumping = "jumping"
const punching_high_left = "punching_high_left"
const punching_high_right = "punching_high_right"
const punching_low_left = "punching_low_left"
const punching_low_right = "punching_low_right"
const running_in_place = "running_in_place"
const sprinting_in_place = "sprinting_in_place"
const walking_in_place = "walking_in_place"

# State machine variables
var animations_crouching = [crawling_in_place, crouching_idle]
var animations_flying = [flying, flying_fast]
var animations_hanging = [hanging_idle]
var animations_jumping = [falling_idle]
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_animation_locked: bool = false
var is_climbing: bool = false
var is_crouching: bool = false
var is_double_jumping: bool = false
var is_flying: bool = false
var is_hanging: bool = false
var is_jumping: bool = false
var is_kicking_left: bool = false
var is_kicking_right: bool = false
var is_punching_left: bool = false
var is_punching_right: bool = false
var is_sprinting: bool = false
var timer_jump: float = 0.0

# Note: `@export` variables are available for editing in the property editor.
@export var enable_double_jump: bool = false
@export var enable_vibration: bool = false
@export var enable_flying: bool = false
@export var force_kicking: float = 2.0
@export var force_kicking_sprinting: float = 3.0
@export var force_punching: float = 1.0
@export var force_punching_sprinting: float = 1.5
@export var force_pushing: float = 1.0
@export var force_pushing_sprinting: float = 2.0
@export var look_sensitivity_controller: float = 120.0
@export var look_sensitivity_mouse: float = 0.2
@export var look_sensitivity_virtual: float = 60.0
@export var perspective: int = 0
@export var player_crawling_speed: float = 0.75
@export var player_current_speed: float = 3.0
@export var player_jump_velocity: float = 4.5
@export var player_fast_flying_speed: float = 10.0
@export var player_flying_speed: float = 5.0
@export var player_running_speed: float = 3.5
@export var player_sprinting_speed: float = 5.0
@export var player_walking_speed: float = 1.0

# Note: `@onready` variables are set when the scene is loaded.
@onready var animation_player = $Visuals/AuxScene/AnimationPlayer
@onready var camera_mount = $CameraMount
@onready var camera = $CameraMount/Camera3D
@onready var player_skeleton = $Visuals/AuxScene/Node/Skeleton3D
@onready var raycast_jumptarget = $Visuals/RayCast3D_JumpTarget
@onready var raycast_top = $Visuals/RayCast3D_InFrontPlayer_Top
@onready var raycast_high = $Visuals/RayCast3D_InFrontPlayer_High
@onready var raycast_middle = $Visuals/RayCast3D_InFrontPlayer_Middle
@onready var raycast_low = $Visuals/RayCast3D_InFrontPlayer_Low
@onready var raycast_below = $Visuals/RayCast3D_BelowPlayer
@onready var visuals = $Visuals


## Called when the node leaves the scene tree.
func _exit_tree() -> void:

	# [DEBUG] Message
	if Globals.debug_mode: print(Globals.time_stamp, " [DEBUG] '", get_script().resource_path.get_file().get_basename(), "' scene unloaded.")


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# [DEBUG] Message
	if Globals.debug_mode: print(Globals.time_stamp, " [DEBUG] '", get_script().resource_path.get_file().get_basename(), "' scene loaded.")

	# Define the initial control configuration
	setup_controls()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
## Use _input(event) if you only need to respond to discrete input events, such as detecting a single press or release of a key or button.
func _input(event) -> void:

	# If the game is not paused...
	if !Globals.game_paused:

		# Check for mouse motion
		if event is InputEventMouseMotion:
			# Rotate camera based on mouse movement
			camera_rotate_by_mouse(event)

		# Check if the animation player is not locked
		if !is_animation_locked:

			# [kick-left] button _pressed_ (while on a floor, but not crouching)
			if event.is_action_pressed("left_kick") and is_on_floor() and !is_crouching:
				# Flag the animation player as locked
				is_animation_locked = true
				# Flag the player as "kicking with their left leg"
				is_kicking_left = true
				# Check if the animation player is not already playing the appropriate animation
				if animation_player.current_animation != kicking_low_left:
					# Play the left "kicking" animation
					animation_player.play(kicking_low_left)
				# Check the kick hits something
				check_kick_collision()

			# [kick-right] button _pressed_ (while on a floor, but not crouching)
			if event.is_action_pressed("right_kick") and is_on_floor() and !is_crouching:
				# Flag the animation player as locked
				is_animation_locked = true
				# Flag the player as "kicking with their right leg"
				is_kicking_right = true
				# Check if the animation player is not already playing the appropriate animation
				if animation_player.current_animation != kicking_low_right:
					# Play the right "kicking" animation
					animation_player.play(kicking_low_right)
				# Check the kick hits something
				check_kick_collision()

			# [punch-left] button _pressed_ (while on a floor, but not crouching)
			if event.is_action_pressed("left_punch") and is_on_floor() and !is_crouching:
				# Flag the animation player as locked
				is_animation_locked = true
				# Flag the player as "punching with their left arm"
				is_punching_left = true
				# Check if the player is crouching
				if is_crouching:
					# Check if the animation player is not already playing the appropriate animation
					if animation_player.current_animation != punching_low_left:
						# Play the left, low "punching" animation
						animation_player.play(punching_low_left)
				# The player should be standing
				else:
					# Check if the animation player is not already playing the appropriate animation
					if animation_player.current_animation != punching_high_left:
						# Play the left "punching" animation
						animation_player.play(punching_high_left)
				# Check the punch hits something
				check_punch_collision()

			# [punch-right] button _pressed_ (while on a floor, but not crouching)
			if event.is_action_pressed("right_punch") and is_on_floor() and !is_crouching:
				# Flag the animation player as locked
				is_animation_locked = true
				# Flag the player as "punching with their right arm"
				is_punching_right = true
				# Check if the player is crouching
				if is_crouching:
					# Check if the animation player is not already playing the appropriate animation
					if animation_player.current_animation != punching_low_right:
						# Play the right, low "punching" animation
						animation_player.play(punching_low_right)
				# The player should be standing
				else:
					# Check if the animation player is not already playing the appropriate animation
					if animation_player.current_animation != punching_high_right:
						# Play the right "punching" animation
						animation_player.play(punching_high_right)
				# Check the punch hits something
				check_punch_collision()

		# [select] button _pressed_
		if event.is_action_pressed("select"):
			if perspective == 0:
				# Flag the player as in "first" person
				perspective = 1
				# Set camera's position
				camera.position = Vector3(0.0, 0.0, 0.0)
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
				# Set the visual's rotation
				visuals.rotation = Vector3(0.0, 0.0, 0.0)


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
## Use _physics_process(delta) if the input needs to be checked continuously in sync with the physics engine, like for smooth movement or jump control.
func _physics_process(delta) -> void:

	# Check if no animation is playing
	if !animation_player.is_playing():
		# Play the idle "Standing" animation
		animation_player.play(idle)
		# Flag the animation player no longer locked
		is_animation_locked = false
		# Reset player state
		is_kicking_left = false
		is_kicking_right = false
		is_punching_left = false
		is_punching_right = false

	# Set the player's idle animation, as needed
	set_player_idle_animation()

	# If the game is not paused...
	if !Globals.game_paused:

		# set animation and velocity based on player action and position
		mangage_state()

		# Handle [look_*] using controller
		var look_actions = ["look_down", "look_up", "look_left", "look_right"]
		# Check each "look" action in the list
		for action in look_actions:
			# Check if the action is _pressesd_
			if Input.is_action_pressed(action):

				# Rotate camera based on controller movement
				camera_rotate_by_controller(delta)

		# Handle player movement
		update_velocity(delta)

		# Check if the animation player is unlocked and the player's motion is unlocked
		if !is_animation_locked and !Globals.movement_locked:
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


## Check the eyeline for a ledge to grab.
func check_top_edge_collision() -> void:
	if !raycast_top.is_colliding() and raycast_high.is_colliding() and !is_climbing:
		# Check if the current animation is not a "hanging" one
		if animation_player.current_animation != hanging_idle:
			# Play the idle "Hanging" animation
			animation_player.play(hanging_idle)
		# Adjust for the animation's player position
		var point = raycast_high.get_collision_point()
		# Determine the direction away from the wall
		var offset_direction = (position - point).normalized()
		# Offset the player by half the width away from the wall
		position = Vector3(point.x + offset_direction.x * 0.2, position.y - 0.45, point.z + offset_direction.z * 0.2)
		# Flag the animation player as locked
		is_animation_locked = true
		# Flag the player as "hanging" (from a ledge)
		is_hanging = true
		# Flag the player as not jumping
		is_jumping = false
		# Reset velocity to prevent any movement
		velocity = Vector3.ZERO
		# Delay execution
		await get_tree().create_timer(0.2).timeout
		# Flag the animation player no longer locked
		is_animation_locked = false


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


## Start the player flying.
func flying_start() -> void:
	gravity = 0.0
	motion_mode = MOTION_MODE_FLOATING
	position.y += 0.1
	velocity.y = 0.0
	is_flying = true


## Stop the player flying.
func flying_stop() -> void:
	gravity = 9.8
	motion_mode = MOTION_MODE_GROUNDED
	velocity.y -= gravity
	visuals.rotation.x = 0
	is_flying = false


## Manage the player's state; setting flags and playing animations.
func mangage_state() -> void:

	# [sprint] button _pressed_ (and the animation player is not locked)
	if Input.is_action_pressed("sprint") and !is_animation_locked:
		# Flag the player as "sprinting"
		is_sprinting = true
	
	# [sprint] button just _released_
	if Input.is_action_just_released("sprint"):
		# Flag the player as no longer "sprinting"
		is_sprinting = false
	
	# Check if the player is flying
	if is_flying:

		# [crouch] button just _pressed_
		if Input.is_action_just_pressed("crouch"):
			# Pitch the player slightly downward
			visuals.rotation.x = deg_to_rad(-6)
		
		# [crouch] button currently _pressed_
		if Input.is_action_pressed("crouch"):
			# Decrease the player's vertical position
			position.y -= 0.1
			# End flying if collision detected below the player
			if raycast_below.is_colliding():
				# Stop flying
				flying_stop()
		
		# [crouch] button just _released_
		if Input.is_action_just_released("crouch"):
			# Reset the player's pitch
			visuals.rotation.x = 0

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump"):
			# Pitch the player slightly downward
			visuals.rotation.x = deg_to_rad(6)

		# [jump] button currently _pressed_
		if Input.is_action_pressed("jump"):
			# Increase the player's vertical position
			position.y += 0.1

		# [jump] button just _released_
		if Input.is_action_just_released("jump"):
			# Reset the player's pitch
			visuals.rotation.x = 0

		# [sprint] button _pressed_
		if Input.is_action_pressed("sprint"):
			# Check if the current animation is not a flying one
			if animation_player.current_animation != flying_fast:
				# Play the idle "flying Fast" animation
				animation_player.play(flying_fast)
		else:
			# Check if the current animation is not a flying one
			if animation_player.current_animation not in animations_flying:
				# Play the idle "flying" animation
				animation_player.play(flying)

	# Check if the player is hanging (from a ledge)
	if is_hanging:

		# [crouch] button currently _pressed_ (and the animation played is unlocked)
		if Input.is_action_pressed("crouch") and !is_animation_locked:
			# Flag the player as no longer "hanging"
			is_hanging = false
			# Make the player start falling again
			velocity.y = -gravity
			# Play the idle "falling" animation
			animation_player.play(falling_idle)

		# [jump] button just _pressed_ (and the animation player is unlocked)
		if Input.is_action_just_pressed("jump") and !is_animation_locked:
			# Flag the player as no longer "hanging"
			is_hanging = false
			# Flag the player as "climbing" (from a ledge)
			is_climbing = true
			# Make the player start falling again
			velocity.y = -gravity
			# Play the idle "Standing" animation
			animation_player.play(idle)
			# Find the target position
			var collision_point = raycast_jumptarget.get_collision_point()
			# Move the player
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", collision_point, 0.2)
			# Delay execution
			await get_tree().create_timer(0.2).timeout
			# Flag the player as no longer "climbing"
			is_climbing = false

	# Check if player is on a floor
	if is_on_floor():

		# Reset the jumping flags
		is_jumping = false
		is_double_jumping = false

		# [crouch] button currently _pressed_ (and the animation played is unlocked)
		if Input.is_action_pressed("crouch") and !is_animation_locked:
			# Flag the player as "crouching"
			is_crouching = true

		# [crouch] button just _released_
		if Input.is_action_just_released("crouch"):
			# Flag player as no longer "crouching"
			is_crouching = false

		# [jump] button just _pressed_ (and the animation player is unlocked)
		if Input.is_action_just_pressed("jump") and !is_animation_locked:
			# Set the player's vertical velocity
			velocity.y = player_jump_velocity
			# Flag the player as not "double jumping"
			is_double_jumping = false
			# Flag the player as "jumping"
			is_jumping = true
			# Play the "jumping" animation
			animation_player.play(jumping)
	
	# The player should not be on a floor and not flying
	else:

		# Edge detection
		check_top_edge_collision()
		
		# [crouch] button just _released_
		if Input.is_action_just_released("crouch"):
			# Flag player as no longer "crouching"
			is_crouching = false

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump"):

				# Check if "double jump" is enabled and the player is not currently double-jumping
				if enable_double_jump and !is_double_jumping:
					# Set the player's vertical velocity
					velocity.y = player_jump_velocity
					# Set the "double jumping" flag
					is_double_jumping = true

				# Check if "flying" is enabled and the player is not already flying
				if enable_flying and !is_flying:
					# Start flying
					flying_start()

				# Check if "flying" but the "jump timer" hasn't started
				if is_flying and timer_jump == 0.0:
					# Set the "jump timer" to the current game time
					timer_jump = Time.get_ticks_msec()
				# Check if "flying" and the "jump timer" is already running
				elif is_flying and timer_jump > 0.0:
					# Get the current game time
					var time_now = Time.get_ticks_msec()
					# Check if _this_ button press is within 200 milliseconds
					if time_now - timer_jump < 200:
						# Stop flying
						flying_stop()
					# Either way, reset the timer
					timer_jump = Time.get_ticks_msec()


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


## Sets the player's idle animation based on status.
func set_player_idle_animation() -> void:

	# Check if the player is "crouching"
	if is_crouching:
		# Check if the current animation is not a crouching one
		if animation_player.current_animation not in animations_crouching:
			# Play the idle "Crouching" animation
			animation_player.play(crouching_idle)
	# The player should not be crouching
	else:
		# Check if the current animation is still a crouching one
		if animation_player.current_animation in animations_crouching:
			# Play the standing "idle" animation
			animation_player.play(idle)
	
	# Check if the player is "flying"
	if is_flying:
		# Check if the current animation is not a flying one
		if animation_player.current_animation not in animations_flying:
			# Play the idle "flying" animation
			animation_player.play(flying)
	# The player should not be flying
	else:
		# Check if the current animation is still a flying one
		if animation_player.current_animation in animations_flying:
			# Play the standing "idle" animation
			animation_player.play(idle)

	# Check if the player is "hanging"
	if is_hanging:
		# Check if the current animation is not a hanging one
		if animation_player.current_animation not in animations_hanging:
			# Play the idle "Hanging" animation
			animation_player.play(hanging_idle)
	
	# Check if the player is "jumping"
	if is_jumping:
		# Check if the current animation is not a jumping one
		if animation_player.current_animation not in animations_jumping:
			# Play the idle "Falling" animation
			animation_player.play(falling_idle)
	# The player should be "idle"
	else:
		# Check if the current animation is still a jumping one
		if animation_player.current_animation in animations_jumping:
			# Play the standing "idle" animation
			animation_player.play(idle)


## Sets the player's movement speed based on status.
func set_player_speed(input_magnitude) -> void:
	# Check if the player is crouching or hanging
	if is_crouching or is_hanging:
		# Set the player's movement speed to the "crawling" speed
		player_current_speed = player_crawling_speed
	# Check if the player is flying and sprinting
	elif is_flying and is_sprinting:
		# Set the player's movement speed to "fast flying"
		player_current_speed = player_fast_flying_speed
	# Check if the player if flying (but not sprinting)
	elif is_flying:
		# Set the player's movement speed to "flying"
		player_current_speed = player_flying_speed
	# Check if the player is sprinting (but not flying)
	elif is_sprinting:
		player_current_speed = player_sprinting_speed
	# The player should be walking (or standing)
	else:
		# Determine player speed based on input magnitude (walking or running)
		player_current_speed = lerp(player_walking_speed, player_running_speed, input_magnitude)


## Define the initial control configuration.
func setup_controls():

	# Check if [debug] action is not in the Input Map
	if not InputMap.has_action("debug"):
		
		# Add the [debug] action to the Input Map
		InputMap.add_action("debug")

		# Keyboard [F3]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F3
		InputMap.action_add_event("debug", key_event)

	# Check if [dpad_up] action is not in the Input Map
	if not InputMap.has_action("dpad_up"):

		# Add the [dpad_up] action to the Input Map
		InputMap.add_action("dpad_up")

		# Controller [dpad, up]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_UP
		InputMap.action_add_event("dpad_up", joypad_button_event)

	# Check if [dpad_left] action is not in the Input Map
	if not InputMap.has_action("dpad_left"):

		# Add the [dpad_left] action to the Input Map
		InputMap.add_action("dpad_left")

		# Controller [dpad, left]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_LEFT
		InputMap.action_add_event("dpad_left", joypad_button_event)

	# Check if [dpad_down] action is not in the Input Map
	if not InputMap.has_action("dpad_down"):

		# Add the [dpad_down] action to the Input Map
		InputMap.add_action("dpad_down")

		# Controller [dpad, down]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_DOWN
		InputMap.action_add_event("dpad_down", joypad_button_event)

	# Check if [dpad_right] action is not in the Input Map
	if not InputMap.has_action("dpad_right"):

		# Add the [dpad_right] action to the Input Map
		InputMap.add_action("dpad_right")

		# Controller [dpad, right]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_RIGHT
		InputMap.action_add_event("dpad_right", joypad_button_event)

	# Check if [move_up] action is not in the Input Map
	if not InputMap.has_action("move_up"):

		# Add the [move_up] action to the Input Map
		InputMap.add_action("move_up")

		# Keyboard 🅆
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_W
		InputMap.action_add_event("move_up", key_event)

		# Controller [left-stick, forward]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_Y
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("move_up", joystick_event)

	# Check if [move_left] action is not in the Input Map
	if not InputMap.has_action("move_left"):

		# Add the [move_left] action to the Input Map
		InputMap.add_action("move_left")

		# Keyboard 🄰
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_A
		InputMap.action_add_event("move_left", key_event)

		# Controller [left-stick, left]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_X
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("move_left", joystick_event)

	# Check if [move_down] action is not in the Input Map
	if not InputMap.has_action("move_down"):

		# Add the [move_down] action to the Input Map
		InputMap.add_action("move_down")

		# Keyboard 🅂
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_S
		InputMap.action_add_event("move_down", key_event)

		# Controller [left-stick, backward]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_Y
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("move_down", joystick_event)

	# Check if [move_right] action is not in the Input Map
	if not InputMap.has_action("move_right"):

		# Add the [move_right] action to the Input Map
		InputMap.add_action("move_right")

		# Keyboard 🄳
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_D
		InputMap.action_add_event("move_right", key_event)

		# Controller [left-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("move_right", joystick_event)

	# Check if [select] action is not in the Input Map
	if not InputMap.has_action("select"):
		
		# Add the [select] action to the Input Map
		InputMap.add_action("select")

		# Keyboard [F5]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F5
		InputMap.action_add_event("select", key_event)

		# Controller ⧉
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event("select", joypad_button_event)

	# Check if [start] action is not in the Input Map
	if not InputMap.has_action("start"):
		
		# Add the [start] action to the Input Map
		InputMap.add_action("start")

		# Keyboard [Esc]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event("start", key_event)

		# Controller ☰
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event("start", joypad_button_event)

	# Check if [look_up] action is not in the Input Map
	if not InputMap.has_action("look_up"):

		# Add the [look_up] action to the Input Map
		InputMap.add_action("look_up")

		# Keyboard ⍐
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_UP
		InputMap.action_add_event("look_up", key_event)

		# Controller [right-stick, up]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_Y
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("look_up", joystick_event)

	# Check if [look_left] action is not in the Input Map
	if not InputMap.has_action("look_left"):

		# Add the [look_left] action to the Input Map
		InputMap.add_action("look_left")

		# Keyboard ⍇
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_LEFT
		InputMap.action_add_event("look_left", key_event)

		# Controller [right-stick, left]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("look_left", joystick_event)

	# Check if [look_down] action is not in the Input Map
	if not InputMap.has_action("look_down"):

		# Add the [look_down] action to the Input Map
		InputMap.add_action("look_down")

		# Keyboard ⍗
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_UP
		InputMap.action_add_event("look_down", key_event)

		# Controller [right-stick, down]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_Y
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("look_down", joystick_event)

	# Check if [look_right] action is not in the Input Map
	if not InputMap.has_action("look_right"):

		# Add the [look_right] action to the Input Map
		InputMap.add_action("look_right")

		# Keyboard ⍈
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_LEFT
		InputMap.action_add_event("look_right", key_event)

		# Controller [right-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("look_right", joystick_event)

	# Ⓐ Check if [jump] action is not in the Input Map
	if not InputMap.has_action("jump"):

		# Add the [jump] action to the Input Map
		InputMap.add_action("jump")

		# Keyboard [Space]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SPACE
		InputMap.action_add_event("jump", key_event)

		# Controller Ⓐ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event("jump", joypad_button_event)

	# Ⓑ Check if [sprint] action is not in the Input Map
	if not InputMap.has_action("sprint"):

		# Add the [sprint] action to the Input Map
		InputMap.add_action("sprint")

		# Keyboard [Shift]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SHIFT
		InputMap.action_add_event("sprint", key_event)

		# Controller Ⓑ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_B
		InputMap.action_add_event("sprint", joypad_button_event)

	# Ⓧ Check if [use] action is not in the Input Map
	if not InputMap.has_action("use"):

		# Add the [use] action to the Input Map
		InputMap.add_action("use")

		# Keyboard [E]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("use", key_event)

		# Controller Ⓧ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event("use", joypad_button_event)

	# Ⓨ Check if [crouch] action is not in the Input Map
	if not InputMap.has_action("crouch"):

		# Add the [crouch] action to the Input Map
		InputMap.add_action("crouch")

		# Keyboard [Ctrl]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_CTRL
		InputMap.action_add_event("crouch", key_event)

		# Controller Ⓨ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_Y
		InputMap.action_add_event("crouch", joypad_button_event)

	# 🄻1
	if not InputMap.has_action("left_punch"):

		# Add the [left_punch] action to the Input Map
		InputMap.add_action("left_punch")

		# Mouse [left-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index  = MOUSE_BUTTON_LEFT
		mouse_button_event.pressed = true
		InputMap.action_add_event("left_punch", mouse_button_event)

		# Controller 🄻1
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_LEFT_SHOULDER
		InputMap.action_add_event("left_punch", joypad_button_event)

	# 🄻2
	if not InputMap.has_action("left_kick"):

		# Add the [left_kick] action to the Input Map
		InputMap.add_action("left_kick")

		# Mouse [forward-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index  = MOUSE_BUTTON_XBUTTON2
		mouse_button_event.pressed = true
		InputMap.action_add_event("left_kick", mouse_button_event)

		# Controller 🄻2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_LEFT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("left_kick", joypad_axis_event)

	# Ⓛ3

	# 🅁1
	if not InputMap.has_action("right_punch"):

		# Add the [right_punch] action to the Input Map
		InputMap.add_action("right_punch")

		# Mouse [right-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_RIGHT
		mouse_button_event.pressed = true
		InputMap.action_add_event("right_punch", mouse_button_event)

		# Controller 🅁1
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_RIGHT_SHOULDER
		mouse_button_event.pressed = true
		InputMap.action_add_event("right_punch", joypad_button_event)

	# 🅁2
	if not InputMap.has_action("right_kick"):

		# Add the [right_kick] action to the Input Map
		InputMap.add_action("right_kick")

		# Mouse [back-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_XBUTTON1
		mouse_button_event.pressed = true
		InputMap.action_add_event("right_kick", mouse_button_event)

		# Controller 🅁2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_RIGHT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("right_kick", joypad_axis_event)

	# Ⓡ3


## Update the player's velocity based on input and status.
func update_velocity(delta: float) -> void:

	# Check if the player is not hanging
	if !is_hanging:
		# Add the gravity.
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Calculate the input magnitude (intensity of the left-analog stick)
	var input_magnitude = input_dir.length()
	
	# Set the player's movement speed
	set_player_speed(input_magnitude)
	
	# Check for directional movement
	if direction:
		# Check if the animation player is unlocked
		if !is_animation_locked:
			# Check if the player is on the ground
			if is_on_floor():
				# Check if the player is crouching
				if is_crouching:
					# Play the crouching "move" animation
					if animation_player.current_animation != crawling_in_place:
						animation_player.play(crawling_in_place)
				# Check if the player is sprinting
				elif is_sprinting:
					# Play the sprinting "move" animation
					if animation_player.current_animation != sprinting_in_place:
						animation_player.play(sprinting_in_place)
				# The player must be walking or running
				else:
					# Check if the player is running
					if player_current_speed > (player_running_speed - (player_running_speed - player_walking_speed) * 0.25):
						# Play the walking "move" animation
						if animation_player.current_animation != running_in_place:
							animation_player.play(running_in_place)
					else:
						# Play the walking "move" animation
						if animation_player.current_animation != walking_in_place:
							animation_player.play(walking_in_place)
			# Check if the player is not in "third person" perspective
			if perspective == 0:
				# Update the camera to look in the direction based on player input
				visuals.look_at(position + direction)
			# Update horizontal veolicty
			velocity.x = direction.x * player_current_speed
			# Update vertical veolocity
			velocity.z = direction.z * player_current_speed
	# If no movement detected...
	else:
		# Stop any/all "move" animations
		var animations = ["crawling_in_place", "running_in_place", "walking_in_place"]
		for animation in animations:
			if animation_player.current_animation == animation:
				animation_player.stop()
		# Update horizontal veolicty
		velocity.x = move_toward(velocity.x, 0, player_current_speed)
		# Update vertical veolocity
		velocity.z = move_toward(velocity.z, 0, player_current_speed)
