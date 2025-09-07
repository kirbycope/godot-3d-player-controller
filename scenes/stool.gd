extends Node3D

var is_in_use := false
var player: CharacterBody3D


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if player:
		if !player.game_paused:
			if event.is_action_pressed("button_1"):
				player.is_animation_locked = true
				player.enable_jumping = false
				player.global_position = $Seat.global_position
				player.global_position -= Vector3(0, 0.4, 0) # [Hack] Adjust player visuals
				player.animation_player.play("Sitting_Idle" + "/mixamo_com")
				var current_state_name = player.base_state.get_state_name(player.current_state)
				player.base_state.transition(current_state_name, "Sitting")
			elif event.is_action_pressed("button_0") \
				or event.is_action_pressed("move_down") \
				or event.is_action_pressed("move_left") \
				or event.is_action_pressed("move_right") \
				or event.is_action_pressed("move_up"):
				player.is_animation_locked = false
				player.enable_jumping = true
				player.is_jumping = false
				player.base_state.transition("Sitting", "Standing")


## Called when a node enters the area.
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Player"):
		player = body


## Called when a node enters the area.
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and body.is_in_group("Player"):
		player = null
