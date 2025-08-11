extends Control

const MESSAGE_SCENE: PackedScene = preload("res://addons/3d_player_controller/message.tscn")

@export var time_node_path: String = "" # "Sky3D"
@export var weather_node_path: String = "" # "HUD/BottomRight/Weather"

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
	# [chat] button _released_ and not selecting an emote and not rotating an object
	if event.is_action_released("button_15") and !player.game_paused and !player.emotes_menu.visible and !player.is_rotating_object:

		# Show the chat input
		input_container.show()

		# Focus the input field
		input_field.grab_focus()

		# Disable player movement
		player.game_paused = true

	# [/] slash key _released_
	if event is InputEventKey and event.is_released() and event.keycode == KEY_SLASH and !player.game_paused:

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
	if message_text.begins_with("/"):
		# Handle command
		handle_command(message_text)

	# The message must not be a command
	else:
		# Get the username from the OS environment (Windows)
		var username = OS.get_environment("USERNAME")
		# Check if the username is empty
		if username.is_empty():
			# Get the username from the OS environment (Linux/macOS)
			username = OS.get_environment("USER")

		# Format the message text with italics
		message_text = "[i]" + message_text

		# Always create message locally first for immediate feedback
		#create_message_for_all.rpc(str(Steam.getPersonaName()), message_text)
		create_message_for_all.rpc(username, message_text)

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

		# HELP
		if command == "/help":
			# Show help message
			var commands = [
				"Available commands:",
				"/help - Show [i]this[/i] help message",
				"/noclip - Toggle player collision",
				"/teleport [color=gray]<x> <y> <z>[/color] - Teleport to coordinates",
				"/time [color=gray]<time>[/color] - Change the time of day (between 0.0 and 23.99)",
				"/tp [color=gray]<x> <y> <z>[/color] - Teleport to coordinates (short form)",
				"/weather [color=gray]<condition>[/color] - Change the weather",
			]
			var help_text = "\n".join(commands)
			create_message_for_all.rpc("System", help_text)

		# NOCLIP
		elif command == "/noclip":
			# Toggle player collision
			player.toggle_noclip()
			if player.enable_noclip:
				create_message_for_all.rpc("System", "Noclip enabled")
			else:
				create_message_for_all.rpc("System", "Noclip disabled")

		# TELEPORT
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

		# TIME
		elif command == "/time":
			# Check if there are enough arguments
			if args.size() != 1:
				create_message_for_all.rpc("System", "Usage: /time <time> (between 0.0 and 23.99)")
				return

			# Check if the current [root] scene contains a Time node
			if get_tree().current_scene.has_node(time_node_path):
				var time_value = float(args[0])
				if time_value >= 0.0 and time_value <= 23.99:
					get_tree().current_scene.get_node(time_node_path).current_time = time_value
					create_message_for_all.rpc("System", "Time set to: " + str(time_value))
				else:
					create_message_for_all.rpc("System", "Time must be between 0.0 and 23.99")
			else:
				create_message_for_all.rpc("System", "Time node not found")

		# WEATHER
		elif command == "/weather":
			# Check if there are enough arguments
			if args.size() != 1:
				create_message_for_all.rpc("System", "Usage: /weather <condition>")
				return

			# Check if the current [root] scene contains a Weather node
			if get_tree().current_scene.has_node(weather_node_path):
				var condition = args[0].to_lower()
				if condition not in ["bluesky", "cloudy", "rain", "heavy_rain", "storm", "snow", "heavy_snow"]:
					create_message_for_all.rpc("System", "Weather must be: bluesky, cloudy, rain, heavy_rain, storm, snow, or heavy_snow")
					return
				var weather_node = get_tree().current_scene.get_node(weather_node_path)
				if weather_node.has_method("apply_weather_effects"):
					# Set the weather condition
					if condition == "bluesky":
						weather_node.apply_weather_effects(0)
					elif condition == "cloudy":
						weather_node.apply_weather_effects(1)
					elif condition == "rain":
						weather_node.apply_weather_effects(2)
					elif condition == "heavy_rain":
						weather_node.apply_weather_effects(3)
					elif condition == "storm":
						weather_node.apply_weather_effects(4)
					elif condition == "snow":
						weather_node.apply_weather_effects(5)
					elif condition == "heavy_snow":
						weather_node.apply_weather_effects(6)
					else:
						create_message_for_all.rpc("System", "Unknown weather condition: " + condition)
				else:
					create_message_for_all.rpc("System", "Weather node does not have 'apply_weather_effects' method")
			else:
				create_message_for_all.rpc("System", "Weather node not found")

		# UNKNOWN
		else:
			create_message_for_all.rpc("System", "Unknown command: " + command)
