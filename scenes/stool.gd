extends Node3D

var is_in_use := false
var player: CharacterBody3D


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the player is not null
	if player:
		# Check if the game is not paused
		if !player.game_paused:
			# Check if a player is near
			if event.is_action_pressed("button_1"):
				# Lock the animation layer for a moment
				player.is_animation_locked = true
				# [Hack] Move the player into the seat
				player.global_position = global_position
				# Wait a moment
				await get_tree().create_timer(0.2).timeout
				# Unlock the animation layer
				player.is_animation_locked = false
				# Get the current state name
				var current_state_name = player.base_state.get_state_name(player.current_state)
				# Transition to sitting state
				player.base_state.transition(current_state_name, "Sitting")


## Called when a node enters the area.
func _on_area_3d_body_entered(body):
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Save a reference to the player
		player = body


## Called when a node enters the area.
func _on_area_3d_body_exited(body):
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Clear the reference to the player
		player = null
