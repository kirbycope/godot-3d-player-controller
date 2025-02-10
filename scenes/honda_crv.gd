extends VehicleBody3D

var engine_power
var player: CharacterBody3D
var near_driver_door: int = false
var last_mouse_move_time: float = 0.0

@export var horse_power: float = 190
@export var max_rpm: float = 5000
@export var max_steer: float = 0.9
@export var gear_ratio: float = 3.5
@export var final_drive_ratio: float = 3.9
@export var wheel_radius: float = 0.4

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_player2: AudioStreamPlayer3D = $AudioStreamPlayer3D2
@onready var drivers_seat: Node3D = $DriverSeatPosition
@onready var exit_driver_door: Node3D = $ExitDriverDoorEnd
@onready var open_driver_door: Node3D = $OpenDriverDoorStart
@onready var sound_accelerate = preload("res://assets/sounds/PATHACC.WAV")
@onready var sound_cruise = preload("res://assets/sounds/PATHCRUZE.WAV")
@onready var sound_door_close = preload("res://assets/sounds/CTruck.WAV")
@onready var sound_door_open = preload("res://assets/sounds/OTruck.WAV")
@onready var sound_idle = preload("res://assets/sounds/PATHIDLE.WAV")
@onready var sound_horn = preload("res://assets/sounds/HORNBMW328.WAV")

var driving = preload("res://addons/3d_player_controller/states/driving.gd")


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

			# [crouch] action _pressed_
			if event.is_action_pressed("crouch"):

				# Check if the player is driving
				if player.is_driving:

					# Transition animation
					player.is_driving = false
					player.is_animation_locked = true
					player.global_position.y = player.global_position.y - 0.1
					player.animation_player.play("Exiting_Car")
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
					player.animation_player.play("Standing_Idle")
					player.global_position = exit_driver_door.global_position
					player.global_position.y = exit_driver_door.global_position.y - 0.1
					player.global_rotation = exit_driver_door.global_rotation
					player.camera_mount.rotation.y = 0
					player.is_animation_locked = false
					await get_tree().create_timer(0.1).timeout

					# Start "standing"
					player.base_state.transition("Driving", "Standing")

			# [jump] action _pressed_
			if event.is_action_pressed("jump"):

				# Check if the player is driving
				if player.is_driving:

					# Set the secondary audio stream to the horn sound
					audio_player2.stream = sound_horn

					# Play the horn sound
					audio_player2.play()

			# [use] action _pressed_ (and no player is driving)
			if event.is_action_pressed("use"):

				# Check if the player is near the driver's door
				if near_driver_door:

					# Store the vehicle with the player
					player.is_driving_in = self

					# Transition animation
					player.collision_shape.disabled = true
					player.is_animation_locked = true
					player.global_position = open_driver_door.global_position
					player.global_rotation = open_driver_door.global_rotation
					player.animation_player.play("Entering_Car")
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
					player.animation_player.stop()
					player.animation_player.play(driving.animation_driving)

					# Get the string name of the player's current state
					var current_state = player.base_state.get_state_name(player.current_state)

					# Start "driving"
					player.base_state.transition(current_state, "Driving")


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Convert HP to force in Newtons
	engine_power = (horse_power * 5252 * gear_ratio * final_drive_ratio) / (max_rpm * wheel_radius)


## Called during the physics processing step of the main loop.
func _physics_process(delta: float) -> void:

	# Check if the player is not null
	if player:

		# Check if the player is driving
		if player.is_driving:

			# Check if the current animation is the driving animation
			if player.animation_player.current_animation == driving.animation_driving:

				# Turns the wheels based on the steering value
				steering = move_toward(steering, Input.get_axis("move_right", "move_left") * max_steer, delta * 10)

				# Accelerate the car based on the engine force
				engine_force = Input.get_axis("move_down", "move_up") * engine_power

				# Set the player's rotation to match the driver's seat postion
				player.global_position = drivers_seat.global_position

				# Set the player's rotation to match the driver's seat postion
				player.visuals.global_rotation = drivers_seat.global_rotation

				# Rotate camera only if 2 seconds have passed since the last mouse movement
				if Time.get_ticks_msec() / 1000.0 - last_mouse_move_time > 2.0:
					player.camera_mount.global_rotation.x = lerp_angle(player.camera_mount.global_rotation.x, drivers_seat.global_rotation.x, delta * 5.0)
					player.camera_mount.global_rotation.y = lerp_angle(player.camera_mount.global_rotation.y, drivers_seat.global_rotation.y, delta * 5.0)
					player.camera_mount.global_rotation.z = lerp_angle(player.camera_mount.global_rotation.z, drivers_seat.global_rotation.z, delta * 5.0)

				# Default to the "cruise" sound
				var target_stream: AudioStream = sound_cruise

				# Check the car's current speed
				var speed = linear_velocity.length()

				# Check if the car is not accelerating
				if engine_force == 0.0 and speed < 1.0:

					# Play the "idle" sound
					target_stream = sound_idle

				# Check if the car is accelerating and has atleast a little speed
				elif engine_force > 0.0 and Input.is_action_pressed("move_up") and speed > 5.0:

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


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:

	# Check if the body is a CharacterBody3D
	if body is CharacterBody3D:

		# Store the player
		player = body

		# Flag the player as near the driver's door
		near_driver_door = true


## Called when a Node3D exits the Area3D.
func _on_area_3d_body_exited(body: Node3D) -> void:

	# Check if the body is a CharacterBody3D
	if body is CharacterBody3D:

		# Flag the player as not near the driver's door
		near_driver_door = false
