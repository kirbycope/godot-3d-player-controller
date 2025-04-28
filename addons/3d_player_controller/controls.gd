extends Node

enum InputType {
	MOUSE_KEYBOARD, # 0
	CONTROLLER,	 	# 1
	TOUCH			# 2
}

signal input_type_changed(new_type)

var current_input_type: InputType:
	set(value):
		if current_input_type != value:
			current_input_type = value
			input_type_changed.emit(value)
	get:
		return current_input_type


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the input is a keyboard or mouse event
	if event is InputEventKey or event is InputEventMouse:

		# Set the current input type to Mouse and Keyboard
		current_input_type = InputType.MOUSE_KEYBOARD

	# Check if the input is a controller event
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:

		# Set the current input type to Controller
		current_input_type = InputType.CONTROLLER

	# Check if the input is a touch event
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:

		# Set the current input type to Touch
		current_input_type = InputType.TOUCH


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
	if not InputMap.has_action("dpad_up"):

		# Add the [dpad_up] action to the Input Map
		InputMap.add_action("dpad_up")

		# Controller [dpad, up]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_UP
		InputMap.action_add_event("dpad_up", joypad_button_event)

		# Keyboard [TAB]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_TAB
		InputMap.action_add_event("dpad_up", key_event)

	# Remove [dpad, up] from the Built-In Action "ui_up"
	var events = InputMap.action_get_events("ui_up")
	for event in events:
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_DPAD_UP:
			InputMap.action_erase_event("ui_up", event)

	# Check if [dpad_left] action is not in the Input Map
	if not InputMap.has_action("dpad_left"):

		# Add the [dpad_left] action to the Input Map
		InputMap.add_action("dpad_left")

		# Controller [dpad, left]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_LEFT
		InputMap.action_add_event("dpad_left", joypad_button_event)

		# Keyboard [B]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_B
		InputMap.action_add_event("dpad_left", key_event)

	# Remove [dpad, left] from the Built-In Action "ui_left"
	events = InputMap.action_get_events("ui_left")
	for event in events:
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_DPAD_LEFT:
			InputMap.action_erase_event("ui_left", event)

	# Check if [dpad_down] action is not in the Input Map
	if not InputMap.has_action("dpad_down"):

		# Add the [dpad_down] action to the Input Map
		InputMap.add_action("dpad_down")

		# Controller [dpad, down]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_DOWN
		InputMap.action_add_event("dpad_down", joypad_button_event)

		# Keyboard [Q]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_Q
		InputMap.action_add_event("dpad_down", key_event)

	# Remove [dpad, down] from the Built-In Action "ui_down"
	events = InputMap.action_get_events("ui_down")
	for event in events:
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_DPAD_DOWN:
			InputMap.action_erase_event("ui_down", event)

	# Check if [dpad, right] action is not in the Input Map
	if not InputMap.has_action("dpad_right"):

		# Add the [dpad_down] action to the Input Map
		InputMap.add_action("dpad_right")

		# Controller [dpad, right]
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_DPAD_RIGHT
		InputMap.action_add_event("dpad_right", joypad_button_event)

		# Keyboard [T]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_T
		InputMap.action_add_event("dpad_right", key_event)

	# Remove [dpad, right] from the Built-In Action "ui_right"
	events = InputMap.action_get_events("ui_right")
	for event in events:
		if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_DPAD_RIGHT:
			InputMap.action_erase_event("ui_right", event)

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

	# Check if [select] action is not in the Input Map
	if not InputMap.has_action("select"):
		
		# Add the [select] action to the Input Map
		InputMap.add_action("select")

		# Keyboard [F5]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_F5
		InputMap.action_add_event("select", key_event)

		# Controller ⧉
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_BACK
		InputMap.action_add_event("select", joypad_button_event)

	# Check if [start] action is not in the Input Map
	if not InputMap.has_action("start"):
		
		# Add the [start] action to the Input Map
		InputMap.add_action("start")

		# Keyboard [Esc]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event("start", key_event)

		# Controller ☰
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_START
		InputMap.action_add_event("start", joypad_button_event)

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
		key_event.physical_keycode = KEY_UP
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
		key_event.physical_keycode = KEY_LEFT
		InputMap.action_add_event("look_right", key_event)

		# Controller [right-stick, right]
		var joystick_event = InputEventJoypadMotion.new()
		joystick_event.axis = JOY_AXIS_RIGHT_X
		joystick_event.axis_value = 1.0
		InputMap.action_add_event("look_right", joystick_event)

	# Ⓐ Check if [jump] action is not in the Input Map
	if not InputMap.has_action("jump"):

		# Add the [jump] action to the Input Map
		InputMap.add_action("jump")

		# Keyboard [Space]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SPACE
		InputMap.action_add_event("jump", key_event)

		# Controller Ⓐ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_A
		InputMap.action_add_event("jump", joypad_button_event)

	# Ⓑ Check if [sprint] action is not in the Input Map
	if not InputMap.has_action("sprint"):

		# Add the [sprint] action to the Input Map
		InputMap.add_action("sprint")

		# Keyboard [Shift]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_SHIFT
		InputMap.action_add_event("sprint", key_event)

		# Controller Ⓑ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_B
		InputMap.action_add_event("sprint", joypad_button_event)

	# Ⓧ Check if [use] action is not in the Input Map
	if not InputMap.has_action("use"):

		# Add the [use] action to the Input Map
		InputMap.add_action("use")

		# Keyboard [E]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("use", key_event)

		# Controller Ⓧ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_X
		InputMap.action_add_event("use", joypad_button_event)

	# Ⓨ Check if [crouch] action is not in the Input Map
	if not InputMap.has_action("crouch"):

		# Add the [crouch] action to the Input Map
		InputMap.add_action("crouch")

		# Keyboard [Ctrl]
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_CTRL
		InputMap.action_add_event("crouch", key_event)

		# Controller Ⓨ
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_Y
		InputMap.action_add_event("crouch", joypad_button_event)

	# 🄻1 Check if [left_punch] action is not in the Input Map
	if not InputMap.has_action("left_punch"):

		# Add the [left_punch] action to the Input Map
		InputMap.add_action("left_punch")

		# Mouse [left-click]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index  = MOUSE_BUTTON_LEFT
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
		mouse_button_event.button_index  = MOUSE_BUTTON_XBUTTON2
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
		mouse_button_event.button_index  = MOUSE_BUTTON_RIGHT
		mouse_button_event.pressed = true
		InputMap.action_add_event("aim", mouse_button_event)

		# Controller 🄻2
		var joypad_axis_event = InputEventJoypadMotion.new()
		joypad_axis_event.axis = JOY_AXIS_TRIGGER_LEFT
		joypad_axis_event.axis_value = 1.0
		InputMap.action_add_event("aim", joypad_axis_event)

	# Ⓛ3 Check if [zoom_in] action
	if not InputMap.has_action("zoom_in"):

		# Add the [zoom_in] action to the Input Map
		InputMap.add_action("zoom_in")

		# Mouse [scroll-up]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index  = MOUSE_BUTTON_WHEEL_DOWN
		mouse_button_event.pressed = true
		InputMap.action_add_event("zoom_in", mouse_button_event)
		
		# Controller 🄻3
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_LEFT_STICK
		InputMap.action_add_event("zoom_in", joypad_button_event)

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
	if not InputMap.has_action("zoom_out"):
		
		# Add the [zoom_out] action to the Input Map
		InputMap.add_action("zoom_out")

		# Mouse [scroll-up]
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index  = MOUSE_BUTTON_WHEEL_UP
		mouse_button_event.pressed = true
		InputMap.action_add_event("zoom_out", mouse_button_event)

		# Controller 🄻3
		var joypad_button_event = InputEventJoypadButton.new()
		joypad_button_event.button_index = JOY_BUTTON_RIGHT_STICK
		InputMap.action_add_event("zoom_out", joypad_button_event)
