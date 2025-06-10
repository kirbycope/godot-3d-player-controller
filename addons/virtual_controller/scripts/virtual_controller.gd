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
	SuperNintendoEntertainmentSystem,
}

const BD_NAVBAR = "#563d7c"		# PURPLE, LIGHT .bd-navbar
const BTN_DANGER = "#dc3545"	# RED .btn-danger
const BTN_DARK = "#343a40"		# BLACK .btn-dark
const BTN_PRIMARY = "#007bff" 	# BLUE .btn-primary
const BTN_SECONDARY = "#6c757d"	# GRAY .btn-secondary
const BTN_SUCCESS = "#28a745"	# GREEN .btn-success
const BTN_WARNING = "#ffc107"	# YELLOW .btn-warning
const OLD_BV = "#322348"		# PURPLE, DARK .old-bv
const MAX_DISTANCE := 64
const SWIPE_DEADZONE := 8

@export var current_theme = theme.DEFAULT
@export var enable_analog_sticks := true

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

@onready var player = get_parent().get_parent()
@onready var touch_screen_button_down: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomLeft/TouchScreenButtonDown"
@onready var touch_screen_button_left: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomLeft/TouchScreenButtonLeft"
@onready var touch_screen_button_right: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomLeft/TouchScreenButtonRight"
@onready var touch_screen_button_up: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomLeft/TouchScreenButtonUp"
@onready var touch_screen_button_select: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomLeft/TouchScreenButtonSelect"
@onready var touch_screen_button_a: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomRight/TouchScreenButtonA"
@onready var touch_screen_button_b: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomRight/TouchScreenButtonB"
@onready var touch_screen_button_x: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomRight/TouchScreenButtonX"
@onready var touch_screen_button_y: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomRight/TouchScreenButtonY"
@onready var touch_screen_button_start: TouchScreenButton = $"../VirtualButtons/VirtualButtonsBottomRight/TouchScreenButtonStart"
@onready var touch_screen_button_l_1: TouchScreenButton = $"../VirtualButtons/VirtualButtonsTopLeft/TouchScreenButtonL1"
@onready var touch_screen_button_l_2: TouchScreenButton = $"../VirtualButtons/VirtualButtonsTopLeft/TouchScreenButtonL2"
@onready var touch_screen_button_r_1: TouchScreenButton = $"../VirtualButtons/VirtualButtonsTopRight/TouchScreenButtonR1"
@onready var touch_screen_button_r_2: TouchScreenButton = $"../VirtualButtons/VirtualButtonsTopRight/TouchScreenButtonR2"


## Called when CanvasItem has been requested to redraw (after queue_redraw is called, either manually or by the engine).
func _draw() -> void:

	# Check if analog sticks are not enabled
	if not enable_analog_sticks:

		# Return without drawing anything
		return

	# Check if there is a left-swipe event
	if left_swipe_event_index != null:

		# Define the position to draw the gray circle
		var draw_position_gray =  left_swipe_initial_position

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
		var draw_position_gray =  right_swipe_initial_position

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

			# Draw a white circle at the event location
			draw_circle(draw_position_white, 48, Color(1.0, 1.0, 1.0, 0.5))


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the input is a Touch event
	if event is InputEventScreenTouch:

		# [touch] screen just _pressed_
		if event.is_pressed():

			# Check if the touch is on any button first
			if is_touch_on_button(event.position):

				# Skip processing this touch event for the virtual controller
				return

			# Check if the touch event took place on the left-half of the screen and the event has not been recorded
			if event.position.x < get_viewport().get_visible_rect().size.x / 2 and !left_swipe_event_index:

				# Record the touch event index
				left_swipe_event_index = event.index

				# Record inital position
				left_swipe_initial_position = event.position

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
		if event.index == left_swipe_event_index:

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
		if event.index == right_swipe_event_index:

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
			if right_swipe_delta.y < -SWIPE_DEADZONE*2:
				Input.action_release("look_down")
				Input.action_press("look_up")
			# Trigger the [look_down] action _pressed_
			elif right_swipe_delta.y > SWIPE_DEADZONE*2:
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


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Check if the current theme is "New Nintendo 3DS"
	if current_theme == theme.NewNintendo3DS:
		touch_screen_button_a.modulate = BTN_DANGER
		touch_screen_button_b.modulate = BTN_WARNING
		touch_screen_button_x.modulate = BTN_PRIMARY
		touch_screen_button_y.modulate = BTN_SUCCESS

	# Check if the current theme is "Nintendo 64"
	elif current_theme == theme.Nintendo64:
		touch_screen_button_down.modulate = BTN_DARK
		touch_screen_button_up.modulate = BTN_DARK
		touch_screen_button_left.modulate = BTN_DARK
		touch_screen_button_right.modulate = BTN_DARK
		touch_screen_button_a.modulate = BTN_PRIMARY
		touch_screen_button_b.modulate = BTN_SUCCESS
		touch_screen_button_x.visible = false
		touch_screen_button_y.visible = false
		touch_screen_button_select.visible = false
		touch_screen_button_start.modulate = BTN_DANGER
		touch_screen_button_l_1.modulate = BTN_DARK
		touch_screen_button_l_2.modulate = BTN_DARK
		touch_screen_button_r_1.modulate = BTN_DARK
		touch_screen_button_r_2.modulate = BTN_DARK

	# Check if the current theme is "Nintendo Entertainment System"
	elif current_theme == theme.NintendoEntertainmentSystem:
		touch_screen_button_down.modulate = BTN_DARK
		touch_screen_button_up.modulate = BTN_DARK
		touch_screen_button_left.modulate = BTN_DARK
		touch_screen_button_right.modulate = BTN_DARK
		touch_screen_button_a.modulate = BTN_DANGER
		touch_screen_button_b.modulate = BTN_DANGER
		touch_screen_button_x.visible = false
		touch_screen_button_y.visible = false
		touch_screen_button_select.modulate = BTN_DARK
		touch_screen_button_start.modulate = BTN_DARK
		touch_screen_button_l_1.visible = false
		touch_screen_button_l_2.visible = false
		touch_screen_button_r_1.visible = false
		touch_screen_button_r_2.visible = false

	# Check if the current theme is "Nintendo GameCube"
	elif current_theme == theme.NintendoGameCube:
		touch_screen_button_down.modulate = BTN_SECONDARY
		touch_screen_button_up.modulate = BTN_SECONDARY
		touch_screen_button_left.modulate = BTN_SECONDARY
		touch_screen_button_right.modulate = BTN_SECONDARY
		touch_screen_button_a.modulate = BTN_SUCCESS
		touch_screen_button_b.modulate = BTN_DANGER
		touch_screen_button_x.modulate = BTN_SECONDARY
		touch_screen_button_y.modulate = BTN_SECONDARY
		touch_screen_button_select.visible = false
		touch_screen_button_start.modulate = BTN_SECONDARY
		touch_screen_button_l_1.modulate = BTN_SECONDARY
		touch_screen_button_l_2.modulate = BTN_SECONDARY
		touch_screen_button_r_1.modulate = BTN_SECONDARY
		touch_screen_button_r_2.modulate = BTN_SECONDARY

	# Check if the current theme is "Super Nintendo Entertainment System"
	elif current_theme == theme.SuperNintendoEntertainmentSystem:
		touch_screen_button_down.modulate = BTN_DARK
		touch_screen_button_up.modulate = BTN_DARK
		touch_screen_button_left.modulate = BTN_DARK
		touch_screen_button_right.modulate = BTN_DARK
		touch_screen_button_a.modulate = OLD_BV
		touch_screen_button_b.modulate = OLD_BV
		touch_screen_button_x.modulate = BD_NAVBAR
		touch_screen_button_y.modulate = BD_NAVBAR
		touch_screen_button_select.modulate = BTN_DARK
		touch_screen_button_start.modulate = BTN_DARK
		touch_screen_button_l_1.modulate = BTN_SECONDARY
		touch_screen_button_l_2.visible = false
		touch_screen_button_r_1.modulate = BTN_SECONDARY
		touch_screen_button_r_2.visible = false


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
