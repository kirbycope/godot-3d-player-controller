extends VehicleBody3D

const DRIVING = preload("res://addons/3d_player_controller/states/driving.gd")

# Note: `@export` variables are available for editing in the property editor.
@export var final_drive_ratio: float = 3.9
@export var gear_ratio: float = 3.5
@export var horse_power: float = 190
@export var max_rpm: float = 5000
@export var max_steer: float = 0.9
@export var steering_speed: float = 5.0
@export var traction_factor: float = 0.7
@export var wheel_radius: float = 0.4


var engine_power
var last_mouse_move_time: float = 0.0
var player: CharacterBody3D
var near_driver_door: int = false

# Barrel roll tracking
var last_z_rotation: float = 0.0
var accumulated_z_rotation: float = 0.0
var barrel_roll_grounded_time: float = 0.0
var barrel_roll_done: bool = false

# Note: `@onready` variables are set when the scene is loaded.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_player2: AudioStreamPlayer3D = $AudioStreamPlayer3D2
@onready var drivers_seat: Node3D = $DriverSeatPosition
@onready var exit_driver_door: Node3D = $ExitDriverDoorEnd
@onready var open_driver_door: Node3D = $OpenDriverDoorStart
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var do_a_barrel_roll = preload("res://assets/sounds/BANK_03_INSTR_000D_SND_0000.wav")
@onready var sound_accelerate = preload("res://assets/honda_crv/Speed Up Inside Car_1.wav")
@onready var sound_door_close = preload("res://assets/honda_crv/Door Close_1.wav")
@onready var sound_door_open = preload("res://assets/honda_crv/Door Open_1.wav")
@onready var sound_idle = preload("res://assets/honda_crv/Engine Running Inside Car_1.wav")
@onready var sound_horn = preload("res://assets/honda_crv/Honk_1.wav")

var time_ungrounded: float = 0.0 ## Tracks the time the vehicle is not grounded.


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the player is not null
	if player:
		# Check if the game is not paused
		if !player.game_paused:
			# Track mouse movement
			if event is InputEventMouseMotion:
				# Log the time of the event
				last_mouse_move_time = Time.get_ticks_msec() / 1000.0

			# Ⓨ/[Ctrl] action _pressed_ and the animation is not locked - Exit vehicle
			if event.is_action_pressed("button_3") and !player.is_animation_locked:
				# Check if the player is DRIVING
				if player.is_driving:
					# Stop the car immediately
					engine_force = 0
					brake = 1.0
					
					# Stop all audio when exiting
					audio_player.stop()
					audio_player2.stop()

					# Check if the vehicle is not on the ground
					if !ray_cast_3d.is_colliding():
						# Exit vehicle on top of the car
						player.global_position = drivers_seat.global_position + Vector3(0, 1.0, 0)
						player.global_rotation = get_tree().current_scene.rotation
						player.visuals.rotation = player.rotation
						player.camera_mount.rotation = player.rotation

					# The vehicle must be grounded
					else:
						# Don't set is_driving = false yet - keep it true to prevent gravity during exit

						# Flag the animation player as locked
						player.is_animation_locked = true
						# Transition animation
						player.global_position.y -= 0.15
						player.animation_player.play("Exiting_Car" + "/mixamo_com")
						
						# Create a tween to synchronize player with car during exit animation
						var sync_tween = create_tween()
						sync_tween.set_loops()
						sync_tween.tween_method(_sync_player_to_car, 0.0, 1.0, 0.016) # ~60fps updates

						await get_tree().create_timer(1.0).timeout
						animation_player.play("door_front_driver_open")
						audio_player2.stream = player.is_driving_in.sound_door_open
						audio_player2.play()
						await get_tree().create_timer(2.3).timeout
						animation_player.play_backwards("door_front_driver_open")
						await get_tree().create_timer(1.0).timeout
						audio_player2.stream = player.is_driving_in.sound_door_close
						audio_player2.play()
						await get_tree().create_timer(0.2).timeout
						player.animation_player.stop()
						sync_tween.kill() # Stop the synchronization tween
						player.animation_player.play("Standing_Idle" + "/mixamo_com")
						player.global_position = exit_driver_door.global_position
						player.rotation = exit_driver_door.rotation
						player.visuals.rotation = exit_driver_door.rotation
						player.camera_mount.rotation = exit_driver_door.rotation

					# Reset player after exiting
					player.velocity = Vector3.ZERO # Reset velocity to prevent flying
					player.is_driving = false # Now set driving to false after positioning
					player.collision_shape.disabled = false # Ensure collision is re-enabled
					player.is_animation_locked = false

					# Reset car controls after exiting
					engine_force = 0
					brake = 0
					steering = 0

					# Start "standing"
					player.base_state.transition("Driving", "Standing")

			# Ⓐ/[Space] action _pressed_ -> Honk the horn
			if event.is_action_pressed("button_0"):
				# Check if the player is DRIVING
				if player.is_driving:
					# Set the secondary audio stream to the horn sound
					audio_player2.stream = sound_horn

					# Play the horn sound
					audio_player2.play()

			# Ⓧ/[Ctrl] action _pressed_ (and no player is DRIVING) -> Enter vehicle
			if event.is_action_pressed("button_2"):

				# Check if the player is near the driver's door
				if near_driver_door:
					# Store the vehicle with the player
					player.is_driving_in = self
					player.is_animation_locked = true
					player.global_position = open_driver_door.global_position

					# Make the player look at the car (similar to climbing system)
					var car_direction = drivers_seat.global_position - player.global_position
					car_direction.y = 0.0
					var look_at_target = player.global_position + car_direction.normalized()
					player.visuals.look_at(look_at_target, Vector3.UP)

					# Transition animation
					player.animation_player.play("Entering_Car" + "/mixamo_com")
					await get_tree().create_timer(1.0).timeout
					animation_player.play("door_front_driver_open")
					audio_player2.stream = sound_door_open
					audio_player2.play()
					await get_tree().create_timer(2.0).timeout
					animation_player.play_backwards("door_front_driver_open")
					await get_tree().create_timer(1.0).timeout
					audio_player2.stream = sound_door_close
					audio_player2.play()
					player.global_position = drivers_seat.global_position
					player.global_rotation = drivers_seat.global_rotation
					player.collision_shape.disabled = true
					player.animation_player.stop()
					player.animation_player.play(DRIVING.ANIMATION_DRIVING)

					# Get the string name of the player's current state
					var current_state = player.base_state.get_state_name(player.current_state)

					# Start "DRIVING"
					player.base_state.transition(current_state, "Driving")


## Called when the node enters the scene tree for the first time.

func _ready() -> void:
	# Convert HP to force in Newtons
	engine_power = (horse_power * 5252 * gear_ratio * final_drive_ratio) / (max_rpm * wheel_radius)

	# Set up physics material if needed
	if not physics_material_override:
		var physics_material = PhysicsMaterial.new()
		physics_material.friction = 1.0
		physics_material.rough = true
		physics_material_override = physics_material

	# Initialize barrel roll tracking
	last_z_rotation = rotation.z
	accumulated_z_rotation = 0.0
	barrel_roll_done = false


## Called during the physics processing step of the main loop.

func _physics_process(delta: float) -> void:

	# Barrel roll tracking
	if not barrel_roll_done:
		var current_z = rotation.z
		var delta_z = wrapf(current_z - last_z_rotation, -PI, PI)
		accumulated_z_rotation += delta_z
		last_z_rotation = current_z

		# If the car is grounded, increment the grounded timer; else, reset it
		if ray_cast_3d.is_colliding():
			barrel_roll_grounded_time += delta
		else:
			barrel_roll_grounded_time = 0.0

		# Reset accumulated_z_rotation if grounded for more than 3 seconds or player is null
		if player == null or barrel_roll_grounded_time > 3.0:
			accumulated_z_rotation = 0.0
			barrel_roll_grounded_time = 0.0

		# Check for a full barrel roll (360 degrees = 2*PI radians)
		if abs(accumulated_z_rotation) >= TAU:
			player.audio_player.stream = do_a_barrel_roll
			player.audio_player.play()
			accumulated_z_rotation = 0.0 # Reset or handle as needed
			barrel_roll_done = true

	# Check if the player if not null
	if player:
		# Check if the player is DRIVING
		if player.is_driving:
			# Check if the current animation is "DRIVING" (not getting in or getting out)
			if player.animation_player.current_animation == DRIVING.ANIMATION_DRIVING:
				# Calculate current speed
				var current_speed = linear_velocity.length()

				# Calculate steering with speed-sensitive adjustment
				var raw_steer = Input.get_axis("move_right", "move_left")
				var speed_factor = clamp(1.0 - (current_speed / 50.0), 0.3, 1.0) # Reduce steering at high speeds
				var target_steer = raw_steer * max_steer * speed_factor

				# Smooth steering transition
				steering = move_toward(steering, target_steer, delta * steering_speed)

				# Calculate engine force with traction consideration
				var acceleration = Input.get_axis("move_down", "move_up")
				var speed_normalized = clamp(current_speed / 30.0, 0.0, 1.0) # Normalize speed for traction calculation
				var traction_multiplier = 1.0 - (1.0 - traction_factor) * speed_normalized

				# Apply engine force with traction and steering compensation
				engine_force = acceleration * engine_power * traction_multiplier

				# Compensate for velocity loss during steering
				if abs(steering) > 0.1:
					# If you need the car to maintain even more speed during turns, you can increase the steering compensation multiplier (currently set to 0.2)
					var steering_compensation = engine_power * 0.2 * abs(steering)
					engine_force += steering_compensation * sign(engine_force)

				# Update player position and rotation
				player.global_position = drivers_seat.global_position
				player.visuals.global_rotation = drivers_seat.global_rotation

				# Camera handling
				if Time.get_ticks_msec() / 1000.0 - last_mouse_move_time > 2.0:
					player.camera_mount.global_rotation.x = lerp_angle(player.camera_mount.global_rotation.x, drivers_seat.global_rotation.x, delta * 5.0)
					player.camera_mount.global_rotation.y = lerp_angle(player.camera_mount.global_rotation.y, drivers_seat.global_rotation.y, delta * 5.0)
					player.camera_mount.global_rotation.z = lerp_angle(player.camera_mount.global_rotation.z, drivers_seat.global_rotation.z, delta * 5.0)

				# Default to the "idle" sound
				var target_stream: AudioStream = sound_idle

				# Check if the car is  accelerating
				if Input.is_action_pressed("move_up"):
					# Play the "accelerate" sound
					target_stream = sound_accelerate

				# Check if the audio player is not playing the target sound
				if audio_player.stream != target_stream:
					# Set the audio player's stream to the target sound
					audio_player.stream = target_stream

				# Check if the audio player is not playing
				if not audio_player.playing:
					# Play the sound
					audio_player.play()

		# Check if grounded
		if ray_cast_3d.is_colliding():
			# [Re]Set the ungrounded time
			time_ungrounded = 0.0


## Flips the vehicle upright.
func flip_vehicle() -> void:
	# Reset rotation to upright
	rotation = Vector3.ZERO
	# Reset linear velocity to prevent flying
	linear_velocity = Vector3.ZERO
	# Reset angular velocity to prevent spinning
	angular_velocity = Vector3.ZERO


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if the body is a Player
	if body.is_in_group("Player"):
		# Store the player
		player = body

		# Flag the player as near the driver's door
		near_driver_door = true


## Called when a Node3D exits the Area3D.
func _on_area_3d_body_exited(body: Node3D) -> void:
	# Check if the body is a Player
	if body.is_in_group("Player"):
		# Flag the player as not near the driver's door
		near_driver_door = false


## Helper method to sync player position with car during exit animation
func _sync_player_to_car(_value: float) -> void:
	if player and player.animation_player.current_animation == "Exiting_Car" + "/mixamo_com":
		player.global_position = drivers_seat.global_position
		player.global_position.y -= 0.15 # Maintain the offset
