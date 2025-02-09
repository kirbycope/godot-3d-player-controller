extends BaseState

const animation_driving = "Driving"
const animation_entering_car = "Entering_Car"
const animation_exiting_car = "Exiting_Car"
var node_name = "Driving"


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
	player.collision_shape.disabled = true


## Stop "driving".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag player as not "driving"
	player.is_driving = false

	# Remove the player from the vehicle
	player.is_driving_in.player = null

	# Remove the vehicle with the player
	player.is_driving_in = null

	# Enable CollisionShape3D
	player.collision_shape.disabled = false
