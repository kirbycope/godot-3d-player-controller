extends VehicleBody3D

var player: CharacterBody3D
var near_driver_door: int = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		if near_driver_door:
			player.driving_in = self
			# Get the string name of the player's current state
			var current_state = player.base_state.get_state_name(player.current_state)
			# Start "driving"
			player.base_state.transition(current_state, "Driving")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		near_driver_door = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		near_driver_door = false
