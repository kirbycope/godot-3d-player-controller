extends Node3D

@onready var player: CharacterBody3D = $Player


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.enable_local_gravity = true


func _on_gravity_area_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("Player"):
		body.is_gravitating_towards = $TheMoon


func _on_gravity_area_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("Player"):
		if body.is_gravitating_towards == $TheMoon:
			body.is_gravitating_towards = null
