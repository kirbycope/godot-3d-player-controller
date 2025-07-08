extends Control

# Player/
#├── AudioStreamPlayer3D
#├── CameraMount/
#│	└── Camera3D/
#│		└── ChatWindow
#├── Controls
#├── States
#└── Visuals

const MESSAGE_SCENE : PackedScene = preload("res://addons/3d_player_controller/message.tscn")

var should_show_messages: bool = false

@onready var chat_display = $VBoxContainer/ChatDisplay/MessageContainer
@onready var input_container = $VBoxContainer/InputContainer
@onready var input_field = $VBoxContainer/InputContainer/MessageInput
@onready var player = get_parent().get_parent().get_parent()
@onready var scroll_container = $VBoxContainer/ChatDisplay
@onready var send_button = $VBoxContainer/InputContainer/SendButton


## Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the input field
	input_container.hide()


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# [chat] button _released_
	if event.is_action_released("dpad_right") and player.game_paused == false:

		# Show the mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		# Show the chat input
		input_container.show()

		# Focus the input field
		input_field.grab_focus()

		# Disable player movement
		player.game_paused = true

	# [cancel] button _pressed_
	if event.is_action_pressed("ui_cancel"):

		# Clear input
		input_field.text = ""

		# Hide the chat input
		input_container.hide()


func _on_cancel_button_pressed() -> void:
	# Clear input field
	input_field.text = ""

	# Hide the input field
	input_container.hide()

	# Enable player movement
	player.game_paused = false


func _on_chat_display_mouse_entered() -> void:
	# Show all messages
	for message in chat_display.get_children():
		if message is Message:
			message.show()


func _on_chat_display_mouse_exited() -> void:
	# Hide messages that should be hidden (timer expired)
	for message in chat_display.get_children():
		if message is Message and message.hide_timer.is_stopped():
			message.hide()


func _on_send_button_pressed() -> void:
	send_message()


func _on_message_input_text_submitted(_text: String) -> void:
	send_message()


func send_message() -> void:
	# Get the text from the input field
	var message_text = input_field.text.strip_edges()

	# Return early if the message is empty
	if message_text.is_empty():
		return

	var username = OS.get_environment("USERNAME")
	if username.is_empty():
		username = OS.get_environment("USER")

	# Always create message locally first for immediate feedback
	#create_message_for_all.rpc(str(Steam.getPersonaName()), message_text)
	create_message_for_all.rpc(username, message_text)

	# [Re]Set refocus on the input field
	#input_field.grab_focus()

	# Close the chat input
	_on_cancel_button_pressed()


@rpc("any_peer", "call_local")
func create_message_for_all(sender: String, message_text: String) -> void:

	var message = MESSAGE_SCENE.instantiate()
	chat_display.add_child(message)
	message.set_message(sender, message_text)

	# Ensure proper display update
	await get_tree().process_frame

	# Scroll to bottom
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
