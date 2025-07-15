extends Control
## chat_window.gd

# Player (player_3d.gd)
#├── AudioStreamPlayer3D
#├── CameraMount
#│	└── Camera3D (camera_3d.gd)
#│		└── ChatWindow (chat_window.gd)
#│			└── Message (message.gd)
#│		└── Debug (debug.gd)
#│		└── Emotes (emotes.gd)
#│		└── Pause (pause.gd)
#│		└── Settings (settings.gd)
#├── CollisionShape3D
#├── Controls (controls.gd)
#├── ShapeCast3D
#├── States
#└── Visuals
#	└── AuxScene
#		└── AnimationPlayer

const MESSAGE_SCENE : PackedScene = preload("res://addons/3d_player_controller/message.tscn")

var last_message_index := 0
var last_message_text := []
var should_show_messages: bool = false

# Note: `@onready` variables are set when the scene is loaded.
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


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Show the chat window if chat is enabled
	visible = player.enable_chat


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# [chat] button _released_
	if event.is_action_released("dpad_right") and !player.game_paused:

		# Show the mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		# Show the chat input
		input_container.show()

		# Focus the input field
		input_field.grab_focus()

		# Disable player movement
		player.game_paused = true

	# [/] slash key _released_
	if event is InputEventKey and event.is_released() and event.keycode == KEY_SLASH and !player.game_paused:

		# Show the mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		# Show the chat input
		input_container.show()

		# Add the character '/' to the input field
		input_field.text += "/"
		input_field.caret_column = 1

		# Focus the input field
		input_field.grab_focus()

		# Disable player movement
		player.game_paused = true

	# [↓] down key _released_
	if event is InputEventKey and event.is_released() and event.keycode == KEY_DOWN and player.game_paused:
		# Check if we can go forward in history (towards newer messages)
		if last_message_index > 1:
			last_message_index -= 1

			# Set input field to message text
			input_field.text = last_message_text[-last_message_index]
			input_field.caret_column = last_message_text[-last_message_index].length()

		# There must not be any more history
		elif last_message_index == 1:
			# Clear the input field when going past the newest message
			last_message_index = 0
			input_field.text = ""
			input_field.caret_column = 0

		# Focus the input field
		input_field.grab_focus()

	# [↑] up key _released_
	if event is InputEventKey and event.is_released() and event.keycode == KEY_UP and player.game_paused:
		# Check if there is history to display and we haven't reached the oldest message
		if last_message_text.size() > 0 and last_message_index < last_message_text.size():
			last_message_index += 1

			# Set input field to message text
			input_field.text = last_message_text[-last_message_index]
			input_field.caret_column = last_message_text[-last_message_index].length()

			# Focus the input field
			input_field.grab_focus()


	# [cancel] button _pressed_
	if event.is_action_pressed("ui_cancel"):

		# Clear input
		input_field.text = ""

		# Hide the chat input
		input_container.hide()


## Called when the "X" (cancel) button is pressed.
func _on_cancel_button_pressed() -> void:
	# Clear input field
	input_field.text = ""

	# Hide the input field
	input_container.hide()

	# Enable player movement
	player.game_paused = false


## Called when the mouse enters the chat display area.
func _on_chat_display_mouse_entered() -> void:
	# Show all messages
	for message in chat_display.get_children():
		if message is Message:
			message.show()


## Called when the mouse exits the chat display area.
func _on_chat_display_mouse_exited() -> void:
	# Hide messages that should be hidden (timer expired)
	for message in chat_display.get_children():
		if message is Message and message.hide_timer.is_stopped():
			message.hide()


## Called when the "Send" button is pressed.
func _on_send_button_pressed() -> void:
	send_message()


## Called when the input field text is submitted (e.g., by pressing Enter).
func _on_message_input_text_submitted(_text: String) -> void:
	send_message()


## Sends a message to all peers.
func send_message() -> void:

	# Get the text from the input field
	var message_text = input_field.text.strip_edges()

	# Return early if the message is empty
	if message_text.is_empty():
		return
	else:
		# Store the last message text for history
		last_message_text.append(message_text)
		last_message_index = 0

	# Check if the message starts with a '/' character
	if last_message_text[-1].begins_with("/"):
		# Handle command
		handle_command(last_message_text[-1])

	# The message must not be a command
	else:
		# Get the username from the OS environment (Windows)
		var username = OS.get_environment("USERNAME")
		# Check if the username is empty
		if username.is_empty():
			# Get the username from the OS environment (Linux/macOS)
			username = OS.get_environment("USER")

		# Always create message locally first for immediate feedback
		#create_message_for_all.rpc(str(Steam.getPersonaName()), last_message_text[-1])
		create_message_for_all.rpc(username, last_message_text[-1])

		# [Re]Set refocus on the input field
		#input_field.grab_focus()

	# Close the chat input
	_on_cancel_button_pressed()


@rpc("any_peer", "call_local")
## Creates a new message for all peers.
func create_message_for_all(sender: String, message_text: String) -> void:
	# Create a new message instance
	var message = MESSAGE_SCENE.instantiate()
	chat_display.add_child(message)
	message.set_message(sender, message_text)

	# Ensure proper display update
	await get_tree().process_frame

	# Scroll to bottom
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value


## Handles commands sent by the player.
func handle_command(message_text: String) -> void:
	if message_text.begins_with("/"):
		# Split the message at spaces to separate command and arguments
		var parts = message_text.split(" ", true)
		# Get the command (in lowercase)
		var command = parts[0].to_lower()
		# Get the arguments (if any)
		var args = parts.slice(1)
		# Handle specific commands
		if command == "/help":
			# Show help message
			var commands = [
				"Available commands:",
				"/help - Show this help message",
				"/teleport <x> <y> <z> - Teleport to coordinates",
				"/tp <x> <y> <z> - Teleport to coordinates (short form)"
			]
			var help_text = "\n".join(commands)
			create_message_for_all.rpc("System", help_text)
		elif command == "/teleport" or command == "/tp":
			# Check if there are enough arguments
			if args.size() != 3:
				create_message_for_all.rpc("System", "Usage: /teleport <x> <y> <z>")
				return
			# Get X
			var x = null
			if args[0] == "~":
				x = player.position.x
			else:
				x = float(args[0])
			var y = null
			# Get Y
			if args[1] == "~":
				y = player.position.y
			else:
				y = float(args[1])
			# Get Z
			var z = null
			if args[2] == "~":
				z = player.position.z
			else:
				z = float(args[2])
			# Teleport the player
			player.position = Vector3(x, y, z)
			# Announce the teleportation
			create_message_for_all.rpc("System", "Teleported to: " + str(player.position))
		else:
			create_message_for_all.rpc("System", "Unknown command: " + command)
