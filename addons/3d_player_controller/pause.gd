extends Control

@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:

	# Check if the [pause] action _pressed_
	if event.is_action_pressed("start"):

		# Toggle game paused
		player.game_paused = !player.game_paused

		# Show the pause menu, if paused
		visible = player.game_paused


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:

	# Toggle mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if player.game_paused else Input.MOUSE_MODE_CAPTURED)


## Close the pause menu
func _on_back_to_game_button_pressed() -> void:

	# Hide the pause menu
	visible = false

	# Unpause the game
	player.game_paused = false


func _on_return_home_button_pressed() -> void:

	# Return the player to the initial position
	player.position = player.initial_position

	# Return to the game
	_on_back_to_game_button_pressed()


## Handle "Leave Game" button _pressed_.
func _on_leave_game_button_pressed() -> void:

	# Close the application
	get_tree().quit()
