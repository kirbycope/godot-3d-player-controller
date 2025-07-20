extends CanvasLayer
# controls.gd
# Script is used to set up the input controls for the game and to handle different input types such as keyboard, mouse, and game controllers.
# This script is part of the Virtual Controller add-on for Godot Engine.

enum InputType {
	KEYBOARD_MOUSE,
	MICROSOFT,
	NINTENDO,
	SONY,
	TOUCH,
}

@export var hide_touch_controls := true
@export var input_deadzone := 0.15

var button_0 = "jump" 			# Key: Space, 							Controller: Ⓐ (Microsoft), Ⓑ (Nintendo), ⮾ (Sony)
var button_1 = "sprint" 		# Key: Shift, 							Controller: Ⓑ (Microsoft), Ⓐ (Nintendo), 🄋 (Sony)
var button_2 = "use" 			# Key: E, 								Controller: Ⓧ (Microsoft), Ⓨ (Nintendo), 🟗 (Sony)
var button_3 = "crouch" 		# Key: Ctrl, 							Controller: Ⓨ (Microsoft), Ⓧ (Nintendo), 🟕 (Sony)
var button_4 = "left_punch"		# Key: Mouse Button 0 (left click), 	Controller: 🄻1
var button_5 = "right_punch"	# Key: Mouse Button 1 (right click), 	Controller: 🅁1
var button_6 = "left_kick"		# Key: Mouse Button 3 (forward), 		Controller: 🄻2
var button_7 = "right_kick"		# Key: Mouse Button 4 (backward), 		Controller: 🅁2
var button_8 = "select"			# Key: F5, 								Controller: ⧉ (Microsoft), ⊖ (Nintendo), ⧉ (Sony)
var button_9 = "start"			# Key: Esc, 							Controller: ☰ (Microsoft), ⊕ (Nintendo), ☰ (Sony)
var button_10 = "zoom_in"		# Key: Mouse scroll up, 				Controller: Ⓛ3
var button_11 = "zoom_out"		# Key: Mouse scroll down, 				Controller: Ⓡ3
var button_12 = "dpad_up"		# Key: Tab, 							Controller: D-Pad Up
var button_13 = "dpad_down"		# Key: Q, 								Controller: D-Pad Down
var button_14 = "dpad_left"		# Key: B, 								Controller: D-Pad Left
var button_15 = "dpad_right"	# Key: T, 								Controller: D-Pad Right
var current_input_type = InputType.KEYBOARD_MOUSE

# Note: `@onready` variables are set when the scene is loaded.
@onready var virtual_buttons: Control = $VirtualButtons


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if [debug] action is not in the Input Map
	if not InputMap.has_action("debug"):
		# Add the [debug] action to the Input Map
		InputMap.add_action("debug")

		# Keyboard [F3]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F3
		InputMap.action_add_event("debug", key_event)

	# Check if [dpad_up] action is not in the Input Map
	if not InputMap.has_action(button_12):
		# Add the [dpad_up] action to the Input Map
		InputMap.add_action(button_12)

		# Controller [dpad, up]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_UP
		InputMap.action_add_event(button_12, joypad_button_event)

		# Keyboard [TAB]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_TAB
		InputMap.action_add_event(button_12, key_event)

	# Check if [dpad_left] action is not in the Input Map
	if not InputMap.has_action(button_14):
		# Add the [dpad_left] action to the Input Map
		InputMap.add_action(button_14)

		# Controller [dpad, left]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_LEFT
		InputMap.action_add_event(button_14, joypad_button_event)

		# Keyboard [B]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_B
		InputMap.action_add_event(button_14, key_event)

	# Check if [dpad_down] action is not in the Input Map
	if not InputMap.has_action(button_13):
		# Add the [dpad_down] action to the Input Map
		InputMap.add_action(button_13)

		# Controller [dpad, down]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_DOWN
		InputMap.action_add_event(button_13, joypad_button_event)

		# Keyboard [Q]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_Q
		InputMap.action_add_event(button_13, key_event)

	# Check if [dpad, right] action is not in the Input Map
	if not InputMap.has_action(button_15):
		# Add the [dpad_down] action to the Input Map
		InputMap.add_action(button_15)

		# Controller [dpad, right]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_RIGHT
		InputMap.action_add_event(button_15, joypad_button_event)

		# Keyboard [T]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_T
		InputMap.action_add_event(button_15, key_event)

	# Check if [move_up] action is not in the Input Map
	if not InputMap.has_action("move_up"):
		# Add the [move_up] action to the Input Map
		InputMap.add_action("move_up")

		# Keyboard 🅆
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_W
		InputMap.action_add_event("move_up", key_event)

		# Controller [left-stick, forward]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_Y
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("move_up", joystick_event)

	# Check if [move_left] action is not in the Input Map
	if not InputMap.has_action("move_left"):
		# Add the [move_left] action to the Input Map
		InputMap.add_action("move_left")

		# Keyboard 🄰
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_A
		InputMap.action_add_event("move_left", key_event)

		# Controller [left-stick, left]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_X
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("move_left", joystick_event)

	# Check if [move_down] action is not in the Input Map
	if not InputMap.has_action("move_down"):
		# Add the [move_down] action to the Input Map
		InputMap.add_action("move_down")

		# Keyboard 🅂
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_S
		InputMap.action_add_event("move_down", key_event)

		# Controller [left-stick, backward]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_Y
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("move_down", joystick_event)

	# Check if [move_right] action is not in the Input Map
	if not InputMap.has_action("move_right"):
		# Add the [move_right] action to the Input Map
		InputMap.add_action("move_right")

		# Keyboard 🄳
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_D
		InputMap.action_add_event("move_right", key_event)

		# Controller [left-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_LEFT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("move_right", joystick_event)

	# Check if [button_8] action is not in the Input Map
	if not InputMap.has_action(button_8):
		# Add the [button_8] action to the Input Map
		InputMap.add_action(button_8)

		# Keyboard [F5]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F5
		InputMap.action_add_event(button_8, key_event)

		# Controller ⧉
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event(button_8, joypad_button_event)

	# Check if [start] action is not in the Input Map
	if not InputMap.has_action(button_9):
		# Add the [start] action to the Input Map
		InputMap.add_action(button_9)

		# Keyboard [Esc]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event(button_9, key_event)

		# Controller ☰
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event(button_9, joypad_button_event)

	# Check if [look_up] action is not in the Input Map
	if not InputMap.has_action("look_up"):
		# Add the [look_up] action to the Input Map
		InputMap.add_action("look_up")

		# Keyboard ⍐
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_UP
		InputMap.action_add_event("look_up", key_event)

		# Controller [right-stick, up]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_Y
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("look_up", joystick_event)

	# Check if [look_left] action is not in the Input Map
	if not InputMap.has_action("look_left"):
		# Add the [look_left] action to the Input Map
		InputMap.add_action("look_left")

		# Keyboard ⍇
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_LEFT
		InputMap.action_add_event("look_left", key_event)

		# Controller [right-stick, left]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = -1.0
		InputMap.action_add_event("look_left", joystick_event)

	# Check if [look_down] action is not in the Input Map
	if not InputMap.has_action("look_down"):
		# Add the [look_down] action to the Input Map
		InputMap.add_action("look_down")

		# Keyboard ⍗
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_DOWN
		InputMap.action_add_event("look_down", key_event)

		# Controller [right-stick, down]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_Y
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("look_down", joystick_event)

	# Check if [look_right] action is not in the Input Map
	if not InputMap.has_action("look_right"):
		# Add the [look_right] action to the Input Map
		InputMap.add_action("look_right")

		# Keyboard ⍈
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_RIGHT
		InputMap.action_add_event("look_right", key_event)

		# Controller [right-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("look_right", joystick_event)

	# Ⓐ Check if [jump] action is not in the Input Map
	if not InputMap.has_action(button_0):
		# Add the [jump] action to the Input Map
		InputMap.add_action(button_0)

		# Keyboard [Space]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SPACE
		InputMap.action_add_event(button_0, key_event)

		# Controller Ⓐ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event(button_0, joypad_button_event)
		# [Hack] for settings menu(s)
		InputMap.action_add_event("ui_accept", joypad_button_event)

	# Ⓑ Check if [sprint] action is not in the Input Map
	if not InputMap.has_action(button_1):
		# Add the [sprint] action to the Input Map
		InputMap.add_action(button_1)

		# Keyboard [Shift]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SHIFT
		InputMap.action_add_event(button_1, key_event)

		# Controller Ⓑ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_B
		InputMap.action_add_event(button_1, joypad_button_event)
		# [Hack] for settings menu(s)
		InputMap.action_add_event("ui_cancel", joypad_button_event)

	# Ⓧ Check if [use] action is not in the Input Map
	if not InputMap.has_action(button_2):
		# Add the [use] action to the Input Map
		InputMap.add_action(button_2)

		# Keyboard [E]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event(button_2, key_event)

		# Controller Ⓧ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event(button_2, joypad_button_event)

	# Ⓨ Check if [crouch] action is not in the Input Map
	if not InputMap.has_action(button_3):
		# Add the [crouch] action to the Input Map
		InputMap.add_action(button_3)

		# Keyboard [Ctrl]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_CTRL
		InputMap.action_add_event(button_3, key_event)

		# Controller Ⓨ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_Y
		InputMap.action_add_event(button_3, joypad_button_event)

	# 🄻1 Check if [left_punch] action is not in the Input Map
	if not InputMap.has_action("left_punch"):
		# Add the [left_punch] action to the Input Map
		InputMap.add_action("left_punch")

		# Mouse [left-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		mouse_button_event.pressed = true
		InputMap.action_add_event("left_punch", mouse_button_event)

		# Controller 🄻1
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_LEFT_SHOULDER
		InputMap.action_add_event("left_punch", joypad_button_event)

	# 🄻2 Check if [left_kick] action is not in the Input Map
	if not InputMap.has_action("left_kick"):
		# Add the [left_kick] action to the Input Map
		InputMap.add_action("left_kick")

		# Mouse [forward-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_XBUTTON2
		mouse_button_event.pressed = true
		InputMap.action_add_event("left_kick", mouse_button_event)

		# Controller 🄻2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_LEFT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("left_kick", joypad_axis_event)

	# 🄻2 Check if [aim] action is not in the Input Map
	if not InputMap.has_action("aim"):
		# Add the [aim] action to the Input Map
		InputMap.add_action("aim")

		# Mouse [right-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_RIGHT
		mouse_button_event.pressed = true
		InputMap.action_add_event("aim", mouse_button_event)

		# Controller 🄻2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_LEFT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("aim", joypad_axis_event)

	# Ⓛ3 Check if [zoom_in] action
	if not InputMap.has_action(button_10):
		# Add the [zoom_in] action to the Input Map
		InputMap.add_action(button_10)

		# Mouse [scroll-up]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_10, mouse_button_event)
		
		# Controller 🄻3
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_LEFT_STICK
		InputMap.action_add_event(button_10, joypad_button_event)

	# 🅁1 Check if [right_punch] action is not in the Input Map
	if not InputMap.has_action("right_punch"):
		# Add the [right_punch] action to the Input Map
		InputMap.add_action("right_punch")

		# Mouse [right-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_RIGHT
		mouse_button_event.pressed = true
		InputMap.action_add_event("right_punch", mouse_button_event)

		# Controller 🅁1
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_RIGHT_SHOULDER
		mouse_button_event.pressed = true
		InputMap.action_add_event("right_punch", joypad_button_event)

	# 🅁2 Check if [right_kick] action is not in the Input Map
	if not InputMap.has_action("right_kick"):
		# Add the [right_kick] action to the Input Map
		InputMap.add_action("right_kick")

		# Mouse [back-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_XBUTTON1
		mouse_button_event.pressed = true
		InputMap.action_add_event("right_kick", mouse_button_event)

		# Controller 🅁2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_RIGHT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("right_kick", joypad_axis_event)

	# 🅁2 Check if [shoot] action is not in the Input Map
	if not InputMap.has_action("shoot"):
		# Add the [shoot] action to the Input Map
		InputMap.add_action("shoot")

		# Mouse [left-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		mouse_button_event.pressed = true
		InputMap.action_add_event("shoot", mouse_button_event)

		# Controller 🅁2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_RIGHT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("shoot", joypad_axis_event)

	# Ⓡ3 Check if [zoom_out] action
	if not InputMap.has_action(button_11):
		# Add the [zoom_out] action to the Input Map
		InputMap.add_action(button_11)

		# Mouse [scroll-up]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_WHEEL_UP
		mouse_button_event.pressed = true
		InputMap.action_add_event(button_11, mouse_button_event)

		# Controller 🄻3
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_RIGHT_STICK
		InputMap.action_add_event(button_11, joypad_button_event)


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Set the current input type
	set_current_input_type(event)

	# Check if the touch controls should be hidden if the input type is not touch
	if hide_touch_controls:
		# Show the virtual touch controls as needed
		virtual_buttons.visible = (current_input_type == InputType.TOUCH)


## Set the current input type.
func set_current_input_type(event: InputEvent) -> void:
	# Check if the input is a keyboard or mouse event
	if event is InputEventKey or event is InputEventMouse:
		# Set the current input type to Keyboard and Mouse
		current_input_type = InputType.KEYBOARD_MOUSE

	# Check if the input is a controller event
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Check if the input is a joypad event
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			# Check if the input is a joystick event
			if event is InputEventJoypadMotion:
				# Check if the motion is within the deadzone
				if abs(event.axis_value) < input_deadzone:
					# Ignore the input event
					return

			# Get device name (converted to lower case)
			var device_name = Input.get_joy_name(event.device).to_lower()

			# Check if the device name indicates it is a Microsoft [XBox] controller
			if device_name.contains("xinput") or device_name.contains("standard"):
				# Set the current input type to Mircosoft
				current_input_type = InputType.MICROSOFT

			# Check if the device name indicates it is a Nintendo [Switch] controller
			elif device_name.contains("nintendo"):
				# Set the current input type to Nintendo
				current_input_type = InputType.NINTENDO

			# Check if the device name indicates it is a Sony [PlayStation] controller
			elif device_name.contains("ps5"):
				# Set the current input type to Sony
				current_input_type = InputType.SONY

	# Check if the input is a touch event
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		# Set the current input type to Touch
		current_input_type = InputType.TOUCH
