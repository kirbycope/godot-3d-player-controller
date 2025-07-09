extends Control
# debug.gd
# Script for the debug UI to display controller input events.
# This script is part of the Virtual Controller add-on for Godot Engine.

@onready var controls: CanvasLayer = get_parent()
@onready var microsoft_controller: Control = $MicrosoftController
@onready var microsoft_stick_l_origin: Vector2 = $MicrosoftController/White/StickL.position
@onready var microsoft_stick_r_origin: Vector2 = $MicrosoftController/White/StickR.position
@onready var nintendo_controller: Control = $NintendoController
@onready var nintendo_stick_l_origin: Vector2 = $NintendoController/White/StickL.position
@onready var nintendo_stick_r_origin: Vector2 = $NintendoController/White/StickR.position
@onready var sony_controller: Control = $SonyController
@onready var sony_stick_l_origin: Vector2 = $SonyController/White/StickL.position
@onready var sony_stick_r_origin: Vector2 = $SonyController/White/StickR.position


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
			if event.is_action_pressed("dpad_up"):
				$MicrosoftController/White/Button12.visible = false
			elif event.is_action_released("dpad_up"):
				$MicrosoftController/White/Button12.visible = true
			# ⍗ (D-Pad Down)
			if event.is_action_pressed("dpad_down"):
				$MicrosoftController/White/Button13.visible = false
			elif event.is_action_released("dpad_down"):
				$MicrosoftController/White/Button13.visible = true
			# ⍇ (D-Pad Left)
			if event.is_action_pressed("dpad_left"):
				$MicrosoftController/White/Button14.visible = false
			elif event.is_action_released("dpad_left"):
				$MicrosoftController/White/Button14.visible = true
			# ⍈ (D-Pad Right)
			if event.is_action_pressed("dpad_right"):
				$MicrosoftController/White/Button15.visible = false
			elif event.is_action_released("dpad_right"):
				$MicrosoftController/White/Button15.visible = true
			# Ⓐ
			if event.is_action_pressed("jump"):
				$MicrosoftController/White/Button0.visible = false
			elif event.is_action_released("jump"):
				$MicrosoftController/White/Button0.visible = true
			# Ⓑ
			if event.is_action_pressed("sprint"):
				$MicrosoftController/White/Button1.visible = false
			elif event.is_action_released("sprint"):
				$MicrosoftController/White/Button1.visible = true
			# Ⓧ
			if event.is_action_pressed("use"):
				$MicrosoftController/White/Button2.visible = false
			elif event.is_action_released("use"):
				$MicrosoftController/White/Button2.visible = true
			# Ⓨ
			if event.is_action_pressed("crouch"):
				$MicrosoftController/White/Button3.visible = false
			elif event.is_action_released("crouch"):
				$MicrosoftController/White/Button3.visible = true
			# ☰ (Start)
			if event.is_action_pressed("start"):
				$MicrosoftController/White/Button9.visible = false
			elif event.is_action_released("start"):
				$MicrosoftController/White/Button9.visible = true
			# ⧉ (Select)
			if event.is_action_pressed("select"):
				$MicrosoftController/White/Button8.visible = false
			elif event.is_action_released("select"):
				$MicrosoftController/White/Button8.visible = true
			# Ⓛ1 (L1)
			if event.is_action_pressed("left_punch"):
				$MicrosoftController/White/Button4.visible = false
			elif event.is_action_released("left_punch"):
				$MicrosoftController/White/Button4.visible = true
			# Ⓛ2 (L2)
			if event.is_action_pressed("left_kick"):
				$MicrosoftController/White/Button6.visible = false
			elif event.is_action_released("left_kick"):
				$MicrosoftController/White/Button6.visible = true
			# Ⓡ1 (R1)
			if event.is_action_pressed("right_punch"):
				$MicrosoftController/White/Button5.visible = false
			elif event.is_action_released("right_punch"):
				$MicrosoftController/White/Button5.visible = true
			# Ⓡ2 (R2)
			if event.is_action_pressed("right_kick"):
				$MicrosoftController/White/Button7.visible = false
			elif event.is_action_released("right_kick"):
				$MicrosoftController/White/Button7.visible = true

		# Check if the current Input Event was triggered by a Nintendo joypad
		if controls.current_input_type == controls.InputType.NINTENDO:

			# Show the controller
			$MicrosoftController.visible = false
			$NintendoController.visible = true
			$SonyController.visible = false

			# ⍐ (D-Pad Up)
			if event.is_action_pressed("dpad_up"):
				$NintendoController/White/Button12.visible = false
			elif event.is_action_released("dpad_up"):
				$NintendoController/White/Button12.visible = true
			# ⍗ (D-Pad Down)
			if event.is_action_pressed("dpad_down"):
				$NintendoController/White/Button13.visible = false
			elif event.is_action_released("dpad_down"):
				$NintendoController/White/Button13.visible = true
			# ⍇ (D-Pad Left)
			if event.is_action_pressed("dpad_left"):
				$NintendoController/White/Button14.visible = false
			elif event.is_action_released("dpad_left"):
				$NintendoController/White/Button14.visible = true
			# ⍈ (D-Pad Right)
			if event.is_action_pressed("dpad_right"):
				$NintendoController/White/Button15.visible = false
			elif event.is_action_released("dpad_right"):
				$NintendoController/White/Button15.visible = true
			# Ⓐ
			if event.is_action_pressed("sprint"):
				$NintendoController/White/Button0.visible = false
			elif event.is_action_released("sprint"):
				$NintendoController/White/Button0.visible = true
			# Ⓑ
			if event.is_action_pressed("jump"):
				$NintendoController/White/Button1.visible = false
			elif event.is_action_released("jump"):
				$NintendoController/White/Button1.visible = true
			# Ⓧ
			if event.is_action_pressed("use"):
				$NintendoController/White/Button2.visible = false
			elif event.is_action_released("use"):
				$NintendoController/White/Button2.visible = true
			# Ⓨ
			if event.is_action_pressed("crouch"):
				$NintendoController/White/Button3.visible = false
			elif event.is_action_released("crouch"):
				$NintendoController/White/Button3.visible = true
			# ☰ (Start)
			if event.is_action_pressed("start"):
				$NintendoController/White/Button9.visible = false
			elif event.is_action_released("start"):
				$NintendoController/White/Button9.visible = true
			# ⧉ (Select)
			if event.is_action_pressed("select"):
				$NintendoController/White/Button8.visible = false
			elif event.is_action_released("select"):
				$NintendoController/White/Button8.visible = true
			# Ⓛ1 (L1)
			if event.is_action_pressed("left_punch"):
				$NintendoController/White/Button4.visible = false
			elif event.is_action_released("left_punch"):
				$NintendoController/White/Button4.visible = true
			# Ⓛ2 (L2)
			if event.is_action_pressed("left_kick"):
				$NintendoController/White/Button6.visible = false
			elif event.is_action_released("left_kick"):
				$NintendoController/White/Button6.visible = true
			# Ⓡ1 (R1)
			if event.is_action_pressed("right_punch"):
				$NintendoController/White/Button5.visible = false
			elif event.is_action_released("right_punch"):
				$NintendoController/White/Button5.visible = true
			# Ⓡ2 (R2)
			if event.is_action_pressed("right_kick"):
				$NintendoController/White/Button7.visible = false
			elif event.is_action_released("right_kick"):
				$NintendoController/White/Button7.visible = true

		# Check if the current Input Event was triggered by a Sony joypad
		if controls.current_input_type == controls.InputType.SONY:

			# Show the controller
			$MicrosoftController.visible = false
			$NintendoController.visible = false
			$SonyController.visible = true

			# ⍐ (D-Pad Up)
			if event.is_action_pressed("dpad_up"):
				$SonyController/White/Button12.visible = false
			elif event.is_action_released("dpad_up"):
				$SonyController/White/Button12.visible = true
			# ⍗ (D-Pad Down)
			if event.is_action_pressed("dpad_down"):
				$SonyController/White/Button13.visible = false
			elif event.is_action_released("dpad_down"):
				$SonyController/White/Button13.visible = true
			# ⍇ (D-Pad Left)
			if event.is_action_pressed("dpad_left"):
				$SonyController/White/Button14.visible = false
			elif event.is_action_released("dpad_left"):
				$SonyController/White/Button14.visible = true
			# ⍈ (D-Pad Right)
			if event.is_action_pressed("dpad_right"):
				$SonyController/White/Button15.visible = false
			elif event.is_action_released("dpad_right"):
				$SonyController/White/Button15.visible = true
			# ⮾ (Cross)
			if event.is_action_pressed("jump"):
				$SonyController/White/Button0.visible = false
			elif event.is_action_released("jump"):
				$SonyController/White/Button0.visible = true
			# 🄋 (Circle)
			if event.is_action_pressed("sprint"):
				$SonyController/White/Button1.visible = false
			elif event.is_action_released("sprint"):
				$SonyController/White/Button1.visible = true
			# 🟗 (Square)
			if event.is_action_pressed("use"):
				$SonyController/White/Button2.visible = false
			elif event.is_action_released("use"):
				$SonyController/White/Button2.visible = true
			# 🟕 (Triangle)
			if event.is_action_pressed("crouch"):
				$SonyController/White/Button3.visible = false
			elif event.is_action_released("crouch"):
				$SonyController/White/Button3.visible = true
			# ☰ (Start)
			if event.is_action_pressed("start"):
				$SonyController/White/Button9.visible = false
			elif event.is_action_released("start"):
				$SonyController/White/Button9.visible = true
			# ⧉ (Select)
			if event.is_action_pressed("select"):
				$SonyController/White/Button8.visible = false
			elif event.is_action_released("select"):
				$SonyController/White/Button8.visible = true
			# Ⓛ1 (L1)
			if event.is_action_pressed("left_punch"):
				$SonyController/White/Button4.visible = false
			elif event.is_action_released("left_punch"):
				$SonyController/White/Button4.visible = true
			# Ⓛ2 (L2)
			if event.is_action_pressed("left_kick"):
				$SonyController/White/Button6.visible = false
			elif event.is_action_released("left_kick"):
				$SonyController/White/Button6.visible = true
			# Ⓡ1 (R1)
			if event.is_action_pressed("right_punch"):
				$SonyController/White/Button5.visible = false
			elif event.is_action_released("right_punch"):
				$SonyController/White/Button5.visible = true
			# Ⓡ2 (R2)
			if event.is_action_pressed("right_kick"):
				$SonyController/White/Button7.visible = false
			elif event.is_action_released("right_kick"):
				$SonyController/White/Button7.visible = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# By default, hide the debug controllers
	hide()
	microsoft_controller.hide()
	nintendo_controller.hide()
	sony_controller.hide()


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
