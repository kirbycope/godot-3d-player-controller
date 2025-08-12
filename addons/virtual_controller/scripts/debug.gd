extends Control
# debug.gd
# Script for the debug UI to display controller input events.
# This script is part of the Virtual Controller add-on for Godot Engine.

# Note: `@onready` variables are set when the scene is loaded.
@onready var controls: CanvasLayer = get_parent()
@onready var microsoft_controller: Control = $MicrosoftController
@onready var microsoft_stick_l_origin: Vector2 = microsoft_controller.get_node("White/StickL").position
@onready var microsoft_stick_r_origin: Vector2 = microsoft_controller.get_node("White/StickR").position
@onready var nintendo_controller: Control = $NintendoController
@onready var nintendo_stick_l_origin: Vector2 = nintendo_controller.get_node("White/StickL").position
@onready var nintendo_stick_r_origin: Vector2 = nintendo_controller.get_node("White/StickR").position
@onready var sony_controller: Control = $SonyController
@onready var sony_stick_l_origin: Vector2 = sony_controller.get_node("White/StickL").position
@onready var sony_stick_r_origin: Vector2 = sony_controller.get_node("White/StickR").position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# By default, hide the debug controllers
	hide()
	microsoft_controller.hide()
	nintendo_controller.hide()
	sony_controller.hide()


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# [debug] button _pressed_
	if event.is_action_pressed("debug"):
		# Toggle "debug" visibility
		visible = !visible

	# Check if the Debug UI is currently displayed
	if visible:
		# Check if the current Input Event was triggered by a Microsoft joypad
		if controls.current_input_type == controls.InputType.MICROSOFT:
			# Show the proper controller
			$MicrosoftController.visible = true
			$NintendoController.visible = false
			$SonyController.visible = false

			# ⍐ (D-Pad Up)
			if event.is_action_pressed("button_12"):
				$MicrosoftController/White/Button12.visible = false
			elif event.is_action_released("button_12"):
				$MicrosoftController/White/Button12.visible = true
			# ⍗ (D-Pad Down)
			if event.is_action_pressed("button_13"):
				$MicrosoftController/White/Button13.visible = false
			elif event.is_action_released("button_13"):
				$MicrosoftController/White/Button13.visible = true
			# ⍇ (D-Pad Left)
			if event.is_action_pressed("button_14"):
				$MicrosoftController/White/Button14.visible = false
			elif event.is_action_released("button_14"):
				$MicrosoftController/White/Button14.visible = true
			# ⍈ (D-Pad Right)
			if event.is_action_pressed("button_15"):
				$MicrosoftController/White/Button15.visible = false
			elif event.is_action_released("button_15"):
				$MicrosoftController/White/Button15.visible = true
			# Ⓐ
			if event.is_action_pressed("button_0"):
				$MicrosoftController/White/Button0.visible = false
			elif event.is_action_released("button_0"):
				$MicrosoftController/White/Button0.visible = true
			# Ⓑ
			if event.is_action_pressed("button_1"):
				$MicrosoftController/White/Button1.visible = false
			elif event.is_action_released("button_1"):
				$MicrosoftController/White/Button1.visible = true
			# Ⓧ
			if event.is_action_pressed("button_2"):
				$MicrosoftController/White/Button2.visible = false
			elif event.is_action_released("button_2"):
				$MicrosoftController/White/Button2.visible = true
			# Ⓨ
			if event.is_action_pressed("button_3"):
				$MicrosoftController/White/Button3.visible = false
			elif event.is_action_released("button_3"):
				$MicrosoftController/White/Button3.visible = true
			# ☰ (Start)
			if event.is_action_pressed("button_9"):
				$MicrosoftController/White/Button9.visible = false
			elif event.is_action_released("button_9"):
				$MicrosoftController/White/Button9.visible = true
			# ⧉ (Select)
			if event.is_action_pressed("button_8"):
				$MicrosoftController/White/Button8.visible = false
			elif event.is_action_released("button_8"):
				$MicrosoftController/White/Button8.visible = true
			# Ⓛ1 (L1)
			if event.is_action_pressed("button_4"):
				$MicrosoftController/White/Button4.visible = false
			elif event.is_action_released("button_4"):
				$MicrosoftController/White/Button4.visible = true
			# Ⓛ2 (L2)
			if event.is_action_pressed("button_6"):
				$MicrosoftController/White/Button6.visible = false
			elif event.is_action_released("button_6"):
				$MicrosoftController/White/Button6.visible = true
			# Ⓡ1 (R1)
			if event.is_action_pressed("button_5"):
				$MicrosoftController/White/Button5.visible = false
			elif event.is_action_released("button_5"):
				$MicrosoftController/White/Button5.visible = true
			# Ⓡ2 (R2)
			if event.is_action_pressed("button_7"):
				$MicrosoftController/White/Button7.visible = false
			elif event.is_action_released("button_7"):
				$MicrosoftController/White/Button7.visible = true

		# Check if the current Input Event was triggered by a Nintendo joypad
		if controls.current_input_type == controls.InputType.NINTENDO:
			# Show the controller
			$MicrosoftController.visible = false
			$NintendoController.visible = true
			$SonyController.visible = false

			# ⍐ (D-Pad Up)
			if event.is_action_pressed("button_12"):
				$NintendoController/White/Button12.visible = false
			elif event.is_action_released("button_12"):
				$NintendoController/White/Button12.visible = true
			# ⍗ (D-Pad Down)
			if event.is_action_pressed("button_13"):
				$NintendoController/White/Button13.visible = false
			elif event.is_action_released("button_13"):
				$NintendoController/White/Button13.visible = true
			# ⍇ (D-Pad Left)
			if event.is_action_pressed("button_14"):
				$NintendoController/White/Button14.visible = false
			elif event.is_action_released("button_14"):
				$NintendoController/White/Button14.visible = true
			# ⍈ (D-Pad Right)
			if event.is_action_pressed("button_15"):
				$NintendoController/White/Button15.visible = false
			elif event.is_action_released("button_15"):
				$NintendoController/White/Button15.visible = true
			# Ⓐ
			if event.is_action_pressed("button_1"):
				$NintendoController/White/Button0.visible = false
			elif event.is_action_released("button_1"):
				$NintendoController/White/Button0.visible = true
			# Ⓑ
			if event.is_action_pressed("button_0"):
				$NintendoController/White/Button1.visible = false
			elif event.is_action_released("button_0"):
				$NintendoController/White/Button1.visible = true
			# Ⓧ
			if event.is_action_pressed("button_2"):
				$NintendoController/White/Button2.visible = false
			elif event.is_action_released("button_2"):
				$NintendoController/White/Button2.visible = true
			# Ⓨ
			if event.is_action_pressed("button_3"):
				$NintendoController/White/Button3.visible = false
			elif event.is_action_released("button_3"):
				$NintendoController/White/Button3.visible = true
			# ☰ (Start)
			if event.is_action_pressed("button_9"):
				$NintendoController/White/Button9.visible = false
			elif event.is_action_released("button_9"):
				$NintendoController/White/Button9.visible = true
			# ⧉ (Select)
			if event.is_action_pressed("button_8"):
				$NintendoController/White/Button8.visible = false
			elif event.is_action_released("button_8"):
				$NintendoController/White/Button8.visible = true
			# Ⓛ1 (L1)
			if event.is_action_pressed("button_4"):
				$NintendoController/White/Button4.visible = false
			elif event.is_action_released("button_4"):
				$NintendoController/White/Button4.visible = true
			# Ⓛ2 (L2)
			if event.is_action_pressed("button_6"):
				$NintendoController/White/Button6.visible = false
			elif event.is_action_released("button_6"):
				$NintendoController/White/Button6.visible = true
			# Ⓡ1 (R1)
			if event.is_action_pressed("button_5"):
				$NintendoController/White/Button5.visible = false
			elif event.is_action_released("button_5"):
				$NintendoController/White/Button5.visible = true
			# Ⓡ2 (R2)
			if event.is_action_pressed("button_7"):
				$NintendoController/White/Button7.visible = false
			elif event.is_action_released("button_7"):
				$NintendoController/White/Button7.visible = true

		# Check if the current Input Event was triggered by a Sony joypad
		if controls.current_input_type == controls.InputType.SONY:
			# Show the controller
			$MicrosoftController.visible = false
			$NintendoController.visible = false
			$SonyController.visible = true

			# ⍐ (D-Pad Up)
			if event.is_action_pressed("button_12"):
				$SonyController/White/Button12.visible = false
			elif event.is_action_released("button_12"):
				$SonyController/White/Button12.visible = true
			# ⍗ (D-Pad Down)
			if event.is_action_pressed("button_13"):
				$SonyController/White/Button13.visible = false
			elif event.is_action_released("button_13"):
				$SonyController/White/Button13.visible = true
			# ⍇ (D-Pad Left)
			if event.is_action_pressed("button_14"):
				$SonyController/White/Button14.visible = false
			elif event.is_action_released("button_14"):
				$SonyController/White/Button14.visible = true
			# ⍈ (D-Pad Right)
			if event.is_action_pressed("button_15"):
				$SonyController/White/Button15.visible = false
			elif event.is_action_released("button_15"):
				$SonyController/White/Button15.visible = true
			# ⮾ (Cross)
			if event.is_action_pressed("button_0"):
				$SonyController/White/Button0.visible = false
			elif event.is_action_released("button_0"):
				$SonyController/White/Button0.visible = true
			# 🄋 (Circle)
			if event.is_action_pressed("button_1"):
				$SonyController/White/Button1.visible = false
			elif event.is_action_released("button_1"):
				$SonyController/White/Button1.visible = true
			# 🟗 (Square)
			if event.is_action_pressed("button_2"):
				$SonyController/White/Button2.visible = false
			elif event.is_action_released("button_2"):
				$SonyController/White/Button2.visible = true
			# 🟕 (Triangle)
			if event.is_action_pressed("button_3"):
				$SonyController/White/Button3.visible = false
			elif event.is_action_released("button_3"):
				$SonyController/White/Button3.visible = true
			# ☰ (Start)
			if event.is_action_pressed("button_9"):
				$SonyController/White/Button9.visible = false
			elif event.is_action_released("button_9"):
				$SonyController/White/Button9.visible = true
			# ⧉ (Select)
			if event.is_action_pressed("button_8"):
				$SonyController/White/Button8.visible = false
			elif event.is_action_released("button_8"):
				$SonyController/White/Button8.visible = true
			# Ⓛ1 (L1)
			if event.is_action_pressed("button_4"):
				$SonyController/White/Button4.visible = false
			elif event.is_action_released("button_4"):
				$SonyController/White/Button4.visible = true
			# Ⓛ2 (L2)
			if event.is_action_pressed("button_6"):
				$SonyController/White/Button6.visible = false
			elif event.is_action_released("button_6"):
				$SonyController/White/Button6.visible = true
			# Ⓡ1 (R1)
			if event.is_action_pressed("button_5"):
				$SonyController/White/Button5.visible = false
			elif event.is_action_released("button_5"):
				$SonyController/White/Button5.visible = true
			# Ⓡ2 (R2)
			if event.is_action_pressed("button_7"):
				$SonyController/White/Button7.visible = false
			elif event.is_action_released("button_7"):
				$SonyController/White/Button7.visible = true


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check is the current Input Event was triggered by a controller
	if (controls.current_input_type == controls.InputType.MICROSOFT) \
		or (controls.current_input_type == controls.InputType.NINTENDO) \
		or (controls.current_input_type == controls.InputType.SONY):
		# Get Left-stick magnitude
		var left_stick_input = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)

		# Apply position based on left-stick magnitude
		if left_stick_input.length() > 0:
			if controls.current_input_type == controls.InputType.MICROSOFT:
				# Move StickL based on stick input strength
				$MicrosoftController/White/StickL.position = microsoft_stick_l_origin + left_stick_input * 10.0
			elif controls.current_input_type == controls.InputType.NINTENDO:
				# Move StickL based on stick input strength
				$NintendoController/White/StickL.position = nintendo_stick_l_origin + left_stick_input * 10.0
			elif controls.current_input_type == controls.InputType.SONY:
				# Move StickL based on stick input strength
				$SonyController/White/StickL.position = sony_stick_l_origin + left_stick_input * 10.0
		else:
			# Return StickL to its original position when stick is released
			$MicrosoftController/White/StickL.position = microsoft_stick_l_origin
			$NintendoController/White/StickL.position = nintendo_stick_l_origin
			$SonyController/White/StickL.position = sony_stick_l_origin

		# Get right-stick magnitude
		var right_stick_input = Vector2(
			Input.get_axis("look_left", "look_right"),
			Input.get_axis("look_up", "look_down")
		)

		# Apply position based on right-stick magnitude
		if right_stick_input.length() > 0:
			if controls.current_input_type == controls.InputType.MICROSOFT:
				# Move StickR based on stick input strength
				$MicrosoftController/White/StickR.position = microsoft_stick_r_origin + right_stick_input * 10.0
			elif controls.current_input_type == controls.InputType.NINTENDO:
				# Move StickR based on stick input strength
				$NintendoController/White/StickR.position = nintendo_stick_r_origin + right_stick_input * 10.0
			elif controls.current_input_type == controls.InputType.SONY:
				# Move StickR based on stick input strength
				$SonyController/White/StickR.position = sony_stick_r_origin + right_stick_input * 10.0
		else:
			# Return StickR to its original position when stick is released
			$MicrosoftController/White/StickR.position = microsoft_stick_r_origin
			$NintendoController/White/StickR.position = nintendo_stick_r_origin
			$SonyController/White/StickR.position = sony_stick_r_origin
