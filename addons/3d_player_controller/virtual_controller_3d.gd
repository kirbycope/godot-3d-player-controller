extends Node2D

const MAX_DISTANCE := 64
const SWIPE_DEADZONE := 8

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


## Called when CanvasItem has been requested to redraw (after queue_redraw is called, either manually or by the engine).
func _draw() -> void:

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
			if event.position.x > get_viewport().get_visible_rect().size.x / 2 and !right_swipe_event_index and !player.lock_camera:

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
			if right_swipe_delta.x < - SWIPE_DEADZONE*2:
				Input.action_release("look_right")
				Input.action_press("look_left")

			# Trigger the [look_right] action _pressed_
			if right_swipe_delta.x > SWIPE_DEADZONE*2:
				Input.action_release("look_left")
				Input.action_press("look_right")

			# Trigger the [look_up] action _pressed_
			if right_swipe_delta.y < SWIPE_DEADZONE*2:
				Input.action_release("look_down")
				Input.action_press("look_up")

			# Trigger the [look_down] action _pressed_
			if right_swipe_delta.y > SWIPE_DEADZONE*2:
				Input.action_release("look_up")
				Input.action_press("look_down")

	# Redraw canvas items via `_draw()`
	queue_redraw()


## Checks if a given position is within any TouchScreenButton
func is_touch_on_button(position: Vector2) -> bool:

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
			if rect.has_point(position):
				return true

	# If no button was found at the position, return false
	return false
