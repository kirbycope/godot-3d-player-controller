extends VehicleBody3D

var player: CharacterBody3D
var near_driver_door: int = false

@export var max_steer: float = 0.9
@export var engine_power = 300


func _input(event: InputEvent) -> void:

	# [use] action _pressed_ (and no player is driving)
	if event.is_action_pressed("use"):

		# Cehck if the player is near the driver's door
		if near_driver_door:

			# Store the vehicle with the player
			player.driving_in = self

			# Get the string name of the player's current state
			var current_state = player.base_state.get_state_name(player.current_state)

			# Start "driving"
			player.base_state.transition(current_state, "Driving")


func _physics_process(delta: float) -> void:
	if player:
		if player.is_driving:
			steering = move_toward(steering, Input.get_axis("move_right", "move_left") * max_steer, delta * 10)
			engine_force = Input.get_axis("move_down", "move_up") * engine_power
			player.global_position = $DriverSeatPosition.global_position
			player.global_rotation = $DriverSeatPosition.global_rotation


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		near_driver_door = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		near_driver_door = false
