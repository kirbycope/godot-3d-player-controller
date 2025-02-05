extends VehicleBody3D

var player: CharacterBody3D
var near_driver_door: int = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		if near_driver_door:
			player.gravity = 0
			player.get_node("CollisionShape3D").disabled = true
			player.global_position = $OpenDriverDoorStart.global_position
			player.animation_player.play("Entering_Car")
			await get_tree().create_timer(1.0).timeout
			$AnimationPlayer.play("door_front_driver_open")
			await get_tree().create_timer(1.5).timeout
			$AnimationPlayer.play_backwards("door_front_driver_open")
			await get_tree().create_timer(1.0).timeout
			player.global_position = $DriverSeatPosition.global_position - Vector3(0.0, 0.5 , 0.15)
			player.global_rotation = $DriverSeatPosition.global_rotation
			player.animation_player.play("Driving")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		near_driver_door = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		near_driver_door = false
