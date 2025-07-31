extends Control

# Note: `@onready` variables are set when the scene is loaded.
@onready var loading: ColorRect = $Loading
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()
@onready var quit: ColorRect = $Quit
@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer


## Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the "Loading..." message when scene loads
	loading.hide()

	# Connect focus signals for all controls to show visual feedback
	for button in v_box_container.get_children():
			button.focus_entered.connect(_on_button_focus_entered.bind(button))
			button.focus_exited.connect(_on_button_focus_exited.bind(button))


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:
	# Check if the [pause] action _pressed_
	if event.is_action_pressed("button_9"):
		# Toggle game paused
		toggle_pause()


## Close the pause menu.
func _on_back_to_game_button_pressed() -> void:
	# Toggle game paused
	toggle_pause()


## Visual feedback when button gains focus
func _on_button_focus_entered(button: Control):
	# Add a colored border or background to show focus
	button.modulate = Color(0.733, 0.733, 0.733, 1.0)


## Remove visual feedback when button loses focus
func _on_button_focus_exited(button: Control):
	# Return to normal appearance
	button.modulate = Color(1.0, 1.0, 1.0)


## Reload the current scene.
func _on_restart_button_pressed() -> void:
	# Show the "Loading..." message
	loading.show()

	# Wait a moment to ensure the message is displayed
	await get_tree().create_timer(0.1).timeout

	# Get the current scene and reload it
	get_tree().reload_current_scene()


## Send player to their inital position.
func _on_return_home_button_pressed() -> void:
	# Return the player to the initial position
	player.position = player.initial_position

	# Toggle game paused
	toggle_pause()


## Open the settings screen.
func _on_settings_button_pressed() -> void:
	# Toggle settings screen
	toggle_settings()


## Handle "Leave Game" button _pressed_.
func _on_leave_game_button_pressed() -> void:
	# Show the "game ended" message [to web browser users]
	quit.show()

	# Close the application
	get_tree().quit()


## Toggles the pause menu.
func toggle_pause() -> void:
	# Toggle game paused
	player.game_paused = !player.game_paused

	# Toggle mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if player.game_paused else Input.MOUSE_MODE_CAPTURED)

	# Show the pause menu, if paused
	visible = player.game_paused

	# Set focus to first button when opening pause menu
	if visible and v_box_container.get_child_count() > 0:
		v_box_container.get_child(0).grab_focus()


## Toggles the settings menu.
func toggle_settings() -> void:
	# Hide pause menu
	visible = false

	# Show the settings menu
	player.menu_settings.visible = true

	# Set focus to first button when opening settings menu
	player.menu_settings.v_box_container.get_child(0).grab_focus()
