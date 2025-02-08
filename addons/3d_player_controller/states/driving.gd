extends BaseState

const animation_driving = "Driving"
const animation_entering_car = "Entering_Car"
const animation_exiting_car = "Exiting_Car"
var node_name = "Crouching"

## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the player is "driving"
	if player.is_driving:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != animation_driving:

			# Play the "crouching idle, holding rifle" animation
			player.animation_player.play(animation_driving)


## Start "driving".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.DRIVING

	# Flag the player as "driving"
	player.is_driving = true

	# Set the player's movement speed
	player.speed_current = 10.0

	# Disable CollisionShape3D
	player.get_node("CollisionShape3D").disabled = true
	
	player.is_animation_locked = true
	player.gravity = 0
	player.get_node("CollisionShape3D").disabled = true
	player.global_position = player.driving_in.get_node("OpenDriverDoorStart").global_position
	player.animation_player.play("Entering_Car")
	await get_tree().create_timer(1.0).timeout
	player.driving_in.get_node("AnimationPlayer").play("door_front_driver_open")
	await get_tree().create_timer(1.5).timeout
	player.driving_in.get_node("AnimationPlayer").play_backwards("door_front_driver_open")
	await get_tree().create_timer(1.0).timeout
	player.global_position = player.driving_in.get_node("DriverSeatPosition").global_position
	player.global_rotation = player.driving_in.get_node("DriverSeatPosition").global_rotation
	player.animation_player.stop()
	player.animation_player.play("Driving")
	await get_tree().create_timer(5.0).timeout
	player.is_animation_locked = false


## Stop "crouching".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag player as not "crouching"
	player.is_crouching = false

	# Enable CollisionShape3D
	player.get_node("CollisionShape3D").disabled = false
