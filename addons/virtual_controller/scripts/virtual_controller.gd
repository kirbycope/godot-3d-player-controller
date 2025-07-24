extends Node2D
# virtual_controller.gd
# Script for the virtual controller that handles touch input for player movement and camera control.
# This script is part of the Virtual Controller add-on for Godot Engine.

enum theme {
	DEFAULT,
	NewNintendo3DS,
	Nintendo64,
	NintendoEntertainmentSystem,
	NintendoGameCube,
	PlayStationSeries,
	SuperNintendoEntertainmentSystem,
	XBoxSeriesS,
	XBoxSeriesX
}

const ALERT_WARNING = "#856404"			# YELLOW, DARK .alert-warning
const BD_NAVBAR = "#563d7c"				# PURPLE, LIGHT .bd-navbar
const BOOTSTRAP_RED = "#dc3545"			# RED .btn-danger :root{--red: #dc3545;}
const BOOTSTRAP_GRAY_DARK = "#343a40"		# GRAY, DARK .btn-dark :root{--gray-dark: #343a40;}
const BOOTSTRAP_BLUE = "#007bff" 			# BLUE .btn-primary :root{--blue: #007bff;}
const BOOTSTRAP_GRAY = "#6c757d"			# GRAY .btn-secondary :root{--gray: #6c757d;}
const BOOTSTRAP_GREEN = "#28a745"			# GREEN .btn-success :root{--green: #28a745;}
const BOOTSTRAP_YELLOW = "#ffc107"			# YELLOW .btn-warning :root{--yellow: #ffc107;}
const OLD_BV = "#322348"					# PURPLE, DARK .old-bv
const MAX_DISTANCE := 64
const SWIPE_DEADZONE := 8

const BLACK_BUTTON_A = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/Black/2x/buttonA.png")
const BLACK_BUTTON_B = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/Black/2x/buttonB.png")
const BLACK_BUTTON_X = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/Black/2x/buttonX.png")
const BLACK_BUTTON_Y = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/Black/2x/buttonY.png")
const WHITE_BUTTON_A = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/White/2x/buttonA.png")
const WHITE_BUTTON_B = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/White/2x/buttonB.png")
const WHITE_BUTTON_X = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/White/2x/buttonX.png")
const WHITE_BUTTON_Y = preload("res://addons/virtual_controller/assets/textures/game_icons/PNG/White/2x/buttonY.png")

const BLACK_PLAYSTATION_BUTTON_CIRCLE = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/black_playstation_button_circle.png")
const BLACK_PLAYSTATION_BUTTON_CROSS = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/black_playstation_button_cross.png")
const BLACK_PLAYSTATION_BUTTON_SQUARE = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/black_playstation_button_square.png")
const BLACK_PLAYSTATION_BUTTON_TRIANGLE = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/black_playstation_button_triangle.png")
const WHITE_PLAYSTATION_BUTTON_CIRCLE = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/white_playstation_button_circle.png")
const WHITE_PLAYSTATION_BUTTON_CROSS = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/white_playstation_button_cross.png")
const WHITE_PLAYSTATION_BUTTON_SQUARE = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/white_playstation_button_square.png")
const WHITE_PLAYSTATION_BUTTON_TRIANGLE = preload("res://addons/virtual_controller/assets/textures/playstation_series/Double/white_playstation_button_triangle.png")

# Note: `@export` variables are available for editing in the property editor.
@export var current_theme = theme.DEFAULT
@export var enable_analog_stick_left := true
@export var enable_analog_stick_right := true

var left_swipe_current_position = null
var left_swipe_event_index = null
var left_swipe_delta = null
var left_swipe_initial_position = null
var right_swipe_current_position = null
var right_swipe_event_index = null
var right_swipe_delta = null
var right_swipe_initial_position = null
var right_touch_initial_time = null
var tap_event_index = null
var tap_initial_position = null

# Note: `@onready` variables are set when the scene is loaded.
@onready var player = get_parent().get_parent()
@onready var virtual_buttons_bottom_left: Control = $"../VirtualButtons/VirtualButtonsBottomLeft"
@onready var touch_screen_button_down: TouchScreenButton = virtual_buttons_bottom_left.get_node("TouchScreenButtonDown")
@onready var touch_screen_button_left: TouchScreenButton = virtual_buttons_bottom_left.get_node("TouchScreenButtonLeft")
@onready var touch_screen_button_right: TouchScreenButton = virtual_buttons_bottom_left.get_node("TouchScreenButtonRight")
@onready var touch_screen_button_up: TouchScreenButton = virtual_buttons_bottom_left.get_node("TouchScreenButtonUp")
@onready var touch_screen_button_select: TouchScreenButton = virtual_buttons_bottom_left.get_node("TouchScreenButtonSelect")
@onready var touch_screen_button_joystick_l: TouchScreenButton = virtual_buttons_bottom_left.get_node("TouchScreenButtonL")
@onready var virtual_buttons_bottom_right: Control = $"../VirtualButtons/VirtualButtonsBottomRight"
@onready var touch_screen_button_a: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonA")
@onready var touch_screen_button_a_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonA/Background")
@onready var touch_screen_button_a_initial_position := touch_screen_button_a.position
@onready var touch_screen_button_b: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonB")
@onready var touch_screen_button_b_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonB/Background")
@onready var touch_screen_button_b_initial_position := touch_screen_button_b.position
@onready var touch_screen_button_c_up: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonCUp")
@onready var touch_screen_button_c_up_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonCUp/Background")
@onready var touch_screen_button_c_down: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonCDown")
@onready var touch_screen_button_c_down_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonCDown/Background")
@onready var touch_screen_button_c_left: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonCLeft")
@onready var touch_screen_button_c_left_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonCLeft/Background")
@onready var touch_screen_button_c_right: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonCRight")
@onready var touch_screen_button_c_right_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonCRight/Background")
@onready var touch_screen_button_x: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonX")
@onready var touch_screen_button_x_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonX/Background")
@onready var touch_screen_button_x_initial_position := touch_screen_button_x.position
@onready var touch_screen_button_y: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonY")
@onready var touch_screen_button_y_background: Sprite2D = virtual_buttons_bottom_right.get_node("TouchScreenButtonY/Background")
@onready var touch_screen_button_y_initial_position := touch_screen_button_y.position
@onready var touch_screen_button_start: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonStart")
@onready var touch_screen_button_joystick_r: TouchScreenButton = virtual_buttons_bottom_right.get_node("TouchScreenButtonR")
@onready var virtual_buttons_top_left: Control = $"../VirtualButtons/VirtualButtonsTopLeft"
@onready var touch_screen_button_l_1: TouchScreenButton = virtual_buttons_top_left.get_node("TouchScreenButtonL1")
@onready var touch_screen_button_l_2: TouchScreenButton = virtual_buttons_top_left.get_node("TouchScreenButtonL2")
@onready var virtual_buttons_top_right: Control = $"../VirtualButtons/VirtualButtonsTopRight"
@onready var touch_screen_button_r_1: TouchScreenButton = virtual_buttons_top_right.get_node("TouchScreenButtonR1")
@onready var touch_screen_button_r_2: TouchScreenButton = virtual_buttons_top_right.get_node("TouchScreenButtonR2")


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if analog sticks are not enabled
	if not enable_analog_stick_left and not enable_analog_stick_right:
		# Return without drawing anything
		return

	# Check if the input is a Touch event
	if event is InputEventScreenTouch:
		# [touch] screen just _pressed_
		if event.is_pressed():
			# Check if the touch is on any button first
			if is_touch_on_button(event.position):
				# Skip processing this touch event for the virtual controller
				return

			# Check if the left analog stick is enabled
			if enable_analog_stick_left:
				# Check if the touch event took place on the left-half of the screen and the event has not been recorded
				if event.position.x < get_viewport().get_visible_rect().size.x / 2 and !left_swipe_event_index:
					# Record the touch event index
					left_swipe_event_index = event.index

					# Record inital position
					left_swipe_initial_position = event.position

			# Check if the right analog stick is enabled
			if enable_analog_stick_right:
				# Check if the touch event took place on the right-half of the screen and the event has not been recorded
				if event.position.x > get_viewport().get_visible_rect().size.x / 2 and !right_swipe_event_index:
					# Record the touch event index
					right_swipe_event_index = event.index

					# Record inital position
					right_swipe_initial_position = event.position

		# [touch] screen just _released_
		else:
			# Check if the event is related to the left-swipe event
			if event.index == left_swipe_event_index:
				# Reset swipe current position
				left_swipe_current_position = null

				# Reset swipe initial position
				left_swipe_initial_position = null

				# Reset swipe index
				left_swipe_event_index = null

				# Trigger the [move_down] action _released_
				Input.action_release("move_down")

				# Trigger the [move_left] action _released_
				Input.action_release("move_left")

				# Trigger the [move_right] action _released_
				Input.action_release("move_right")

				# Trigger the [move_up] action _released_
				Input.action_release("move_up")

			# Check if the event is related to the right-swipe event
			if event.index == right_swipe_event_index:
				# Reset swipe current position
				right_swipe_current_position = null

				# Reset swipe initial position
				right_swipe_initial_position = null

				# Reset swipe index
				right_swipe_event_index = null

				# Trigger the [look_down] action _released_
				Input.action_release("look_down")

				# Trigger the [look_left] action _released_
				Input.action_release("look_left")

				# Trigger the [look_right] action _released_
				Input.action_release("look_right")

				# Trigger the [look_up] action _released_
				Input.action_release("look_up")

	# Check if the input is a Drag event
	if event is InputEventScreenDrag:
		# Check if the event is related to the left-swipe event
		if event.index == left_swipe_event_index and enable_analog_stick_left:
			# Record swipe current position
			left_swipe_current_position = event.position

			# Calculate the difference between the swipe initial position and the current swipe position
			left_swipe_delta = left_swipe_current_position - left_swipe_initial_position

			# Trigger the [move_left] action _pressed_
			if left_swipe_delta.x < -SWIPE_DEADZONE:
				Input.action_release("move_right")
				Input.action_press("move_left")

			# Trigger the [move_right] action _pressed_
			elif left_swipe_delta.x > SWIPE_DEADZONE:
				Input.action_release("move_left")
				Input.action_press("move_right")

			# Trigger the [move_left] and [move_right] actions _released_
			else:
				Input.action_release("move_left")
				Input.action_release("move_right")

			# Trigger the [move_up] action _pressed_
			if left_swipe_delta.y < -SWIPE_DEADZONE:
				Input.action_release("move_down")
				Input.action_press("move_up")

			# Trigger the [move_down] action _pressed_
			elif left_swipe_delta.y > SWIPE_DEADZONE:
				Input.action_release("move_up")
				Input.action_press("move_down")

			# Trigger the [move_up] and [move_down] actions _released_
			else:
				Input.action_release("move_up")
				Input.action_release("move_down")

		# Check if the event is related to the right-swipe event
		if event.index == right_swipe_event_index and enable_analog_stick_right:
			# Record swipe current position
			right_swipe_current_position = event.position

			# Calculate the difference between the swipe initial position and the current swipe position
			right_swipe_delta = right_swipe_current_position - right_swipe_initial_position

			# Trigger the [look_left] action _pressed_
			if right_swipe_delta.x < -SWIPE_DEADZONE:
				Input.action_release("look_right")
				Input.action_press("look_left")
			# Trigger the [look_right] action _pressed_
			elif right_swipe_delta.x > SWIPE_DEADZONE:
				Input.action_release("look_left")
				Input.action_press("look_right")
			# Trigger the [look_left] and [look_right] actions _released_
			else:
				Input.action_release("look_left")
				Input.action_release("look_right")

			# Trigger the [look_up] action _pressed_
			if right_swipe_delta.y < -SWIPE_DEADZONE * 2:
				Input.action_release("look_down")
				Input.action_press("look_up")
			# Trigger the [look_down] action _pressed_
			elif right_swipe_delta.y > SWIPE_DEADZONE * 2:
				Input.action_release("look_up")
				Input.action_press("look_down")
			# Trigger the [look_up] and [look_down] actions _released_
			else:
				Input.action_release("look_up")
				Input.action_release("look_down")

	# Update button passthrough after all touch processing
	update_button_passthrough()

	# Redraw canvas items via `_draw()`
	queue_redraw()


## Called when CanvasItem has been requested to redraw (after queue_redraw is called, either manually or by the engine).
func _draw() -> void:
	# Check if there is a left-swipe event
	if left_swipe_event_index != null:
		# Define the position to draw the gray circle
		var draw_position_gray = left_swipe_initial_position

		# Draw a gray circle at the event origin
		draw_circle(draw_position_gray, 64, Color(0.502, 0.502, 0.502, 0.5))

		# Check if for drag motion
		if left_swipe_current_position != null:
			# Check if the swipe delta is more than the maximum distance
			if left_swipe_delta.length() > MAX_DISTANCE:
				# Clamp the offset vector's length
				left_swipe_delta = left_swipe_delta.normalized() * MAX_DISTANCE

			# Define the position to draw the white circle
			var draw_position_white = left_swipe_initial_position + left_swipe_delta

			# Draw a white circle at the event location
			draw_circle(draw_position_white, 48, Color(1.0, 1.0, 1.0, 0.5))

	# Check if there is a right-swipe event
	if right_swipe_event_index != null:
		# Define the position to draw the gray circle
		var draw_position_gray = right_swipe_initial_position

		# Check if the theme is Nintendo GameCube
		if current_theme == theme.NintendoGameCube:
			# Draw a dark yellow circle at the event origin
			draw_circle(draw_position_gray, 64, Color(ALERT_WARNING, 0.5))

		# The theme must not be Nintendo GameCube
		else:
			# Draw a gray circle at the event origin
			draw_circle(draw_position_gray, 64, Color(0.502, 0.502, 0.502, 0.5))

		# Check if for drag motion
		if right_swipe_current_position != null:
			# Check if the swipe delta is more than the maximum distance
			if right_swipe_delta.length() > MAX_DISTANCE:
				# Clamp the offset vector's length
				right_swipe_delta = right_swipe_delta.normalized() * MAX_DISTANCE

			# Define the position to draw the white circle
			var draw_position_white = right_swipe_initial_position + right_swipe_delta

			# Check if the theme is Nintendo GameCube
			if current_theme == theme.NintendoGameCube:
				# Draw a yellow circle at the event location
				draw_circle(draw_position_white, 48, Color(BOOTSTRAP_YELLOW, 0.5))

			# The theme must not be Nintendo GameCube
			else:
				# Draw a white circle at the event location
				draw_circle(draw_position_white, 48, Color(1.0, 1.0, 1.0, 0.5))


## Checks if a given position is within any TouchScreenButton.
func is_touch_on_button(event_position: Vector2) -> bool:
	# Get all TouchScreenButton nodes in the scene
	var touch_buttons = get_tree().get_nodes_in_group("TouchScreenButton")

	# Iterate through each button
	for button in touch_buttons:
		# Skip if button is not visible
		if !button.visible:
			continue

		# Get the button's texture and check if the position is within its area
		var texture = button.texture_normal

		# Check if the button has a texture
		if texture:
			# Get the size of the texture
			var size = texture.get_size()

			# Calculate the rectangle area of the button
			var rect = Rect2(button.global_position, size)

			# Check if the position is within the button's rectangle
			if rect.has_point(event_position):
				return true

	# If no button was found at the position, return false
	return false


## Updates button passthrough based on active swipe events.
func update_button_passthrough():
	# Set the "passby_press" of controls on the left side of the viewport
	var should_passthrough = (left_swipe_event_index == null)
	touch_screen_button_down.passby_press = should_passthrough
	touch_screen_button_left.passby_press = should_passthrough
	touch_screen_button_right.passby_press = should_passthrough
	touch_screen_button_up.passby_press = should_passthrough
	touch_screen_button_l_1.passby_press = should_passthrough
	touch_screen_button_l_2.passby_press = should_passthrough

	# Set the "passby_press" of controls on the right side of the viewport
	should_passthrough = (right_swipe_event_index == null)
	touch_screen_button_a.passby_press = should_passthrough
	touch_screen_button_b.passby_press = should_passthrough
	touch_screen_button_x.passby_press = should_passthrough
	touch_screen_button_y.passby_press = should_passthrough
	touch_screen_button_r_1.passby_press = should_passthrough
	touch_screen_button_r_2.passby_press = should_passthrough


## Updates the theme of the virtual controller.
func update_theme(new_theme: theme) -> void:
	# Update the current theme
	current_theme = new_theme

	# Reset the virtual controller state
	enable_analog_stick_left = true
	enable_analog_stick_right = true
	left_swipe_current_position = null
	left_swipe_event_index = null
	left_swipe_delta = null
	left_swipe_initial_position = null
	right_swipe_current_position = null
	right_swipe_event_index = null
	right_swipe_delta = null
	right_swipe_initial_position = null
	right_touch_initial_time = null
	tap_event_index = null
	tap_initial_position = null
	touch_screen_button_down.show()
	touch_screen_button_down.self_modulate = Color.WHITE
	touch_screen_button_left.show()
	touch_screen_button_left.self_modulate = Color.WHITE
	touch_screen_button_right.show()
	touch_screen_button_right.self_modulate = Color.WHITE
	touch_screen_button_up.show()
	touch_screen_button_up.self_modulate = Color.WHITE
	touch_screen_button_select.show()
	touch_screen_button_select.self_modulate = Color.WHITE
	touch_screen_button_joystick_l.show()
	touch_screen_button_joystick_l.self_modulate = Color.WHITE
	touch_screen_button_a.show()
	touch_screen_button_a.texture_normal = WHITE_BUTTON_A
	touch_screen_button_a.texture_pressed = BLACK_BUTTON_A
	touch_screen_button_a.self_modulate = Color.WHITE
	touch_screen_button_a_background.hide()
	touch_screen_button_a_background.self_modulate = Color.BLACK
	touch_screen_button_a.position = touch_screen_button_a_initial_position
	touch_screen_button_b.show()
	touch_screen_button_b.texture_normal = WHITE_BUTTON_B
	touch_screen_button_b.texture_pressed = BLACK_BUTTON_B
	touch_screen_button_b.self_modulate = Color.WHITE
	touch_screen_button_b_background.hide()
	touch_screen_button_b_background.self_modulate = Color.BLACK
	touch_screen_button_b.position = touch_screen_button_b_initial_position
	touch_screen_button_c_up.hide()
	touch_screen_button_c_down.hide()
	touch_screen_button_c_left.hide()
	touch_screen_button_c_right.hide()
	touch_screen_button_c_up_background.hide()
	touch_screen_button_c_down_background.hide()
	touch_screen_button_c_left_background.hide()
	touch_screen_button_c_right_background.hide()
	touch_screen_button_x.show()
	touch_screen_button_x.texture_normal = WHITE_BUTTON_X
	touch_screen_button_x.texture_pressed = BLACK_BUTTON_X
	touch_screen_button_x.self_modulate = Color.WHITE
	touch_screen_button_x_background.hide()
	touch_screen_button_x_background.self_modulate = Color.BLACK
	touch_screen_button_x.position = touch_screen_button_x_initial_position
	touch_screen_button_y.show()
	touch_screen_button_y.texture_normal = WHITE_BUTTON_Y
	touch_screen_button_y.texture_pressed = BLACK_BUTTON_Y
	touch_screen_button_y.self_modulate = Color.WHITE
	touch_screen_button_y_background.hide()
	touch_screen_button_y_background.self_modulate = Color.BLACK
	touch_screen_button_y.position = touch_screen_button_y_initial_position
	touch_screen_button_start.show()
	touch_screen_button_start.self_modulate = Color.WHITE
	touch_screen_button_joystick_r.show()
	touch_screen_button_joystick_r.self_modulate = Color.WHITE
	touch_screen_button_l_1.show()
	touch_screen_button_l_1.self_modulate = Color.WHITE
	touch_screen_button_l_2.show()
	touch_screen_button_l_2.self_modulate = Color.WHITE
	touch_screen_button_r_1.show()
	touch_screen_button_r_1.self_modulate = Color.WHITE
	touch_screen_button_r_2.show()
	touch_screen_button_r_2.self_modulate = Color.WHITE

	# Check if the current theme is "New Nintendo 3DS"
	if current_theme == theme.NewNintendo3DS:
		touch_screen_button_a.self_modulate = BOOTSTRAP_RED
		touch_screen_button_b.self_modulate = BOOTSTRAP_YELLOW
		touch_screen_button_x.self_modulate = BOOTSTRAP_BLUE
		touch_screen_button_y.self_modulate = BOOTSTRAP_GREEN
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = Color.WHITE
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = Color.WHITE
		touch_screen_button_x_background.show()
		touch_screen_button_x_background.self_modulate = Color.WHITE
		touch_screen_button_y_background.show()
		touch_screen_button_y_background.self_modulate = Color.WHITE
		touch_screen_button_a.position = touch_screen_button_b_initial_position
		touch_screen_button_b.position = touch_screen_button_a_initial_position
		touch_screen_button_x.position = touch_screen_button_y_initial_position
		touch_screen_button_y.position = touch_screen_button_x_initial_position

	# Check if the current theme is "Nintendo 64"
	elif current_theme == theme.Nintendo64:
		enable_analog_stick_right = false
		touch_screen_button_up.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_down.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_left.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_right.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a.self_modulate = BOOTSTRAP_BLUE
		touch_screen_button_b.self_modulate = BOOTSTRAP_GREEN
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = Color.GRAY
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = Color.GRAY
		touch_screen_button_c_up.show()
		touch_screen_button_c_up.self_modulate = Color.YELLOW
		touch_screen_button_c_up_background.show()
		touch_screen_button_c_up_background.self_modulate = Color.GRAY
		touch_screen_button_c_down.show()
		touch_screen_button_c_down.self_modulate = Color.YELLOW
		touch_screen_button_c_down_background.show()
		touch_screen_button_c_down_background.self_modulate = Color.GRAY
		touch_screen_button_c_left.show()
		touch_screen_button_c_left.self_modulate = Color.YELLOW
		touch_screen_button_c_left_background.show()
		touch_screen_button_c_left_background.self_modulate = Color.GRAY
		touch_screen_button_c_right.show()
		touch_screen_button_c_right.self_modulate = Color.YELLOW
		touch_screen_button_c_right_background.show()
		touch_screen_button_c_right_background.self_modulate = Color.GRAY
		touch_screen_button_x.hide()
		touch_screen_button_y.hide()
		touch_screen_button_select.hide()
		touch_screen_button_joystick_l.hide()
		touch_screen_button_joystick_r.hide()
		touch_screen_button_start.self_modulate = BOOTSTRAP_RED
		touch_screen_button_l_1.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_l_2.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_r_1.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_r_2.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_b.position = touch_screen_button_x_initial_position

	# Check if the current theme is "Nintendo Entertainment System"
	elif current_theme == theme.NintendoEntertainmentSystem:
		enable_analog_stick_left = false
		enable_analog_stick_right = false
		touch_screen_button_up.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_down.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_left.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_right.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a.self_modulate = BOOTSTRAP_RED
		touch_screen_button_b.self_modulate = BOOTSTRAP_RED
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = Color.BLACK
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = Color.BLACK
		touch_screen_button_x.hide()
		touch_screen_button_y.hide()
		touch_screen_button_select.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_l.hide()
		touch_screen_button_start.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_r.hide()
		touch_screen_button_l_1.hide()
		touch_screen_button_l_2.hide()
		touch_screen_button_r_1.hide()
		touch_screen_button_r_2.hide()
		touch_screen_button_a.position = touch_screen_button_b_initial_position
		touch_screen_button_b.position = touch_screen_button_a_initial_position
		touch_screen_button_x.position = touch_screen_button_y_initial_position
		touch_screen_button_y.position = touch_screen_button_x_initial_position

	# Check if the current theme is "Nintendo GameCube"
	elif current_theme == theme.NintendoGameCube:
		touch_screen_button_up.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_down.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_left.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_right.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_a.self_modulate = BOOTSTRAP_GREEN
		touch_screen_button_b.self_modulate = BOOTSTRAP_RED
		touch_screen_button_x.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_y.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = Color.BLACK
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = Color.BLACK
		touch_screen_button_x_background.show()
		touch_screen_button_x_background.self_modulate = Color.BLACK
		touch_screen_button_y_background.show()
		touch_screen_button_y_background.self_modulate = Color.BLACK
		touch_screen_button_select.hide()
		touch_screen_button_joystick_l.hide()
		touch_screen_button_start.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_joystick_r.hide()
		touch_screen_button_l_1.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_l_2.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_r_1.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_r_2.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_a.position = touch_screen_button_b_initial_position
		touch_screen_button_b.position = touch_screen_button_a_initial_position
		touch_screen_button_x.position = touch_screen_button_y_initial_position
		touch_screen_button_y.position = touch_screen_button_x_initial_position

	# Check if the current theme is "PlayStation Series"
	elif current_theme == theme.PlayStationSeries:
		touch_screen_button_down.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_up.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_left.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_right.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a.texture_normal = WHITE_PLAYSTATION_BUTTON_CROSS
		touch_screen_button_a.texture_pressed = BLACK_PLAYSTATION_BUTTON_CROSS
		touch_screen_button_a.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = BOOTSTRAP_BLUE
		touch_screen_button_b.texture_normal = WHITE_PLAYSTATION_BUTTON_CIRCLE
		touch_screen_button_b.texture_pressed = BLACK_PLAYSTATION_BUTTON_CIRCLE
		touch_screen_button_b.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = BOOTSTRAP_RED
		touch_screen_button_x.texture_normal = WHITE_PLAYSTATION_BUTTON_SQUARE
		touch_screen_button_x.texture_pressed = BLACK_PLAYSTATION_BUTTON_SQUARE
		touch_screen_button_x.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_x_background.show()
		touch_screen_button_x_background.self_modulate = Color.PINK
		touch_screen_button_y.texture_normal = WHITE_PLAYSTATION_BUTTON_TRIANGLE
		touch_screen_button_y.texture_pressed = BLACK_PLAYSTATION_BUTTON_TRIANGLE
		touch_screen_button_y.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_y_background.show()
		touch_screen_button_y_background.self_modulate = BOOTSTRAP_GREEN
		touch_screen_button_select.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_l.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_start.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_r.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_l_1.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_l_2.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_r_1.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_r_2.self_modulate = BOOTSTRAP_GRAY_DARK

	# Check if the current theme is "Super Nintendo Entertainment System"
	elif current_theme == theme.SuperNintendoEntertainmentSystem:
		enable_analog_stick_left = false
		enable_analog_stick_right = false
		touch_screen_button_up.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_down.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_left.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_right.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a.self_modulate = OLD_BV
		touch_screen_button_b.self_modulate = OLD_BV
		touch_screen_button_x.self_modulate = BD_NAVBAR
		touch_screen_button_y.self_modulate = BD_NAVBAR
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = Color.GRAY
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = Color.GRAY
		touch_screen_button_x_background.show()
		touch_screen_button_x_background.self_modulate = Color.GRAY
		touch_screen_button_y_background.show()
		touch_screen_button_y_background.self_modulate = Color.GRAY
		touch_screen_button_select.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_l.hide()
		touch_screen_button_start.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_r.hide()
		touch_screen_button_l_1.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_l_2.hide()
		touch_screen_button_r_1.self_modulate = BOOTSTRAP_GRAY
		touch_screen_button_r_2.hide()
		touch_screen_button_a.position = touch_screen_button_b_initial_position
		touch_screen_button_b.position = touch_screen_button_a_initial_position
		touch_screen_button_x.position = touch_screen_button_y_initial_position
		touch_screen_button_y.position = touch_screen_button_x_initial_position

	# Check if the current theme is "Xbox Series S"
	elif current_theme == theme.XBoxSeriesS:
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = BOOTSTRAP_GREEN
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = BOOTSTRAP_RED
		touch_screen_button_x_background.show()
		touch_screen_button_x_background.self_modulate = BOOTSTRAP_BLUE
		touch_screen_button_y_background.show()
		touch_screen_button_y_background.self_modulate = BOOTSTRAP_YELLOW

	# Check if the current theme is "Xbox Series X"
	elif current_theme == theme.XBoxSeriesX:
		touch_screen_button_down.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_up.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_left.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_right.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_a_background.show()
		touch_screen_button_a_background.self_modulate = BOOTSTRAP_GREEN
		touch_screen_button_b.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_b_background.show()
		touch_screen_button_b_background.self_modulate = BOOTSTRAP_RED
		touch_screen_button_x.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_x_background.show()
		touch_screen_button_x_background.self_modulate = BOOTSTRAP_BLUE
		touch_screen_button_y.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_y_background.show()
		touch_screen_button_y_background.self_modulate = BOOTSTRAP_YELLOW
		touch_screen_button_select.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_l.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_start.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_joystick_r.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_l_1.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_l_2.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_r_1.self_modulate = BOOTSTRAP_GRAY_DARK
		touch_screen_button_r_2.self_modulate = BOOTSTRAP_GRAY_DARK
	
	# Redraw canvas items via `_draw()`
	queue_redraw()
