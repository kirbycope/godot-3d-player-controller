extends Control

@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()
@onready var stick_l_origin: Vector2 = $XboxController/White/StickL.position
@onready var stick_r_origin: Vector2 = $XboxController/White/StickR.position


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:

	# [debug] button _pressed_
	if event.is_action_pressed("debug"):

		# Toggle "debug" visibility
		visible = !visible

	# Check if the Debug UI is currently displayed
	if visible:

		# Check if the current Input Event was triggered by a joypad
		if Controls.current_input_type == Controls.InputType.CONTROLLER:

			# Show the controller
			$XboxController.visible = true

			# Get the joypad's name
			var device_name = Input.get_joy_name(event.device)

			# Check if the joypad is an XBox controller
			if device_name == "XInput Gamepad":

				# ⍐ (D-Pad Up)
				if event.is_action_pressed("dpad_up"):
					$XboxController/White/DPadUp.visible = false
				elif event.is_action_released("dpad_up"):
					$XboxController/White/DPadUp.visible = true
				# ⍗ (D-Pad Down)
				if event.is_action_pressed("dpad_down"):
					$XboxController/White/DPadDown.visible = false
				elif event.is_action_released("dpad_down"):
					$XboxController/White/DPadDown.visible = true
				# ⍇ (D-Pad Left)
				if event.is_action_pressed("dpad_left"):
					$XboxController/White/DPadLeft.visible = false
				elif event.is_action_released("dpad_left"):
					$XboxController/White/DPadLeft.visible = true
				# ⍈ (D-Pad Right)
				if event.is_action_pressed("dpad_right"):
					$XboxController/White/DPadRight.visible = false
				elif event.is_action_released("dpad_right"):
					$XboxController/White/DPadRight.visible = true
				# Ⓐ
				if event.is_action_pressed("jump"):
					$XboxController/White/ButtonA.visible = false
				elif event.is_action_released("jump"):
					$XboxController/White/ButtonA.visible = true
				# Ⓑ
				if event.is_action_pressed("sprint"):
					$XboxController/White/ButtonB.visible = false
				elif event.is_action_released("sprint"):
					$XboxController/White/ButtonB.visible = true
				# Ⓧ
				if event.is_action_pressed("use"):
					$XboxController/White/ButtonX.visible = false
				elif event.is_action_released("use"):
					$XboxController/White/ButtonX.visible = true
				# Ⓨ
				if event.is_action_pressed("crouch"):
					$XboxController/White/ButtonY.visible = false
				elif event.is_action_released("crouch"):
					$XboxController/White/ButtonY.visible = true
				# ☰ (Start)
				if event.is_action_pressed("start"):
					$XboxController/White/ButtonStart.visible = false
				elif event.is_action_released("start"):
					$XboxController/White/ButtonStart.visible = true
				# ⧉ (Select)
				if event.is_action_pressed("select"):
					$XboxController/White/ButtonSelect.visible = false
				elif event.is_action_released("select"):
					$XboxController/White/ButtonSelect.visible = true
				# Ⓛ1 (L1)
				if event.is_action_pressed("left_punch"):
					$XboxController/White/ButtonL1.visible = false
				elif event.is_action_released("left_punch"):
					$XboxController/White/ButtonL1.visible = true
				# Ⓛ2 (L2)
				if event.is_action_pressed("left_kick"):
					$XboxController/White/ButtonL2.visible = false
				elif event.is_action_released("left_kick"):
					$XboxController/White/ButtonL2.visible = true
				# Ⓡ1 (R1)
				if event.is_action_pressed("right_punch"):
					$XboxController/White/ButtonR1.visible = false
				elif event.is_action_released("right_punch"):
					$XboxController/White/ButtonR1.visible = true
				# Ⓡ2 (R2)
				if event.is_action_pressed("right_kick"):
					$XboxController/White/ButtonR2.visible = false
				elif event.is_action_released("right_kick"):
					$XboxController/White/ButtonR2.visible = true

		# Input Event was not triggered by a joypad 
		else:

			# Hide the controller
			$XboxController.visible = false


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Check is the Debug Panel is visible
	if visible:

		# Panel 1
		$Panel1/IsAiming.button_pressed = player.is_aiming
		$Panel1/IsAnimationLocked.button_pressed = player.is_animation_locked
		$Panel1/IsCasting.button_pressed = player.is_casting
		$Panel1/IsClimbing.button_pressed = player.is_climbing
		$Panel1/IsCrawling.button_pressed = player.is_crawling
		$Panel1/IsCrouching.button_pressed = player.is_crouching
		$Panel1/IsDoubleJumping.button_pressed = player.is_double_jumping
		$Panel1/IsDriving.button_pressed = player.is_driving
		$Panel1/IsFalling.button_pressed = player.is_falling
		$Panel1/IsFiring.button_pressed = player.is_firing
		$Panel1/IsFlying.button_pressed = player.is_flying
		$Panel1/IsHanging.button_pressed = player.is_hanging
		$Panel1/IsHolding.button_pressed = player.is_holding
		$Panel1/IsHoldingFishingRod.button_pressed = player.is_holding_fishing_rod
		$Panel1/IsHoldingRifle.button_pressed = player.is_holding_rifle
		$Panel1/IsHoldingTool.button_pressed = player.is_holding_tool
		$Panel1/IsJumping.button_pressed = player.is_jumping
		$Panel1/IsKickingLeft.button_pressed = player.is_kicking_left
		$Panel1/IsKickingRight.button_pressed = player.is_kicking_right
		$Panel1/IsPunchingLeft.button_pressed = player.is_punching_left
		$Panel1/IsPunchingRight.button_pressed = player.is_punching_right
		$Panel1/IsReeling.button_pressed = player.is_reeling
		$Panel1/IsRunning.button_pressed = player.is_running
		$Panel1/IsSkateboarding.button_pressed = player.is_skateboarding
		$Panel1/IsSprinting.button_pressed = player.is_sprinting
		$Panel1/IsStanding.button_pressed = player.is_standing
		$Panel1/IsSwimming.button_pressed = player.is_swimming
		$Panel1/IsUsing.button_pressed = player.is_using
		$Panel1/IsWalking.button_pressed = player.is_walking

		# Panel 2
		$Panel2/EnableCrouching.button_pressed = player.enable_crouching
		$Panel2/EnableChat.button_pressed = player.enable_chat
		$Panel2/EnableDoubleJump.button_pressed = player.enable_double_jump
		$Panel2/EnableFlying.button_pressed = player.enable_flying
		$Panel2/EnableJumping.button_pressed = player.enable_jumping
		$Panel2/EnableKicking.button_pressed = player.enable_kicking
		$Panel2/EnablePunching.button_pressed = player.enable_punching
		$Panel2/EnableVibration.button_pressed = player.enable_vibration
		$Panel2/LockCamera.button_pressed = player.lock_camera
		$Panel2/LockMovementX.button_pressed = player.lock_movement_x
		$Panel2/LockMovementY.button_pressed = player.lock_movement_y
		$Panel2/LockPerspective.button_pressed = player.lock_perspective
		$Panel2/GamePaused.button_pressed = player.game_paused

		# Panel 3
		$FPS/Label.text = "FPS: " + str(int(Engine.get_frames_per_second()))

		# Check is the current Input Event was triggered by a controller
		if Controls.current_input_type == Controls.InputType.CONTROLLER:

			# Get Left-stick magnitude
			var left_stick_input = Vector2(
				Input.get_axis("ui_left", "ui_right"),
				Input.get_axis("ui_up", "ui_down")
			)

			# Apply position based on left-stick magnitude
			if left_stick_input.length() > 0:
				# Move StickL based on stick input strength
				$XboxController/White/StickL.position = stick_l_origin + left_stick_input * 10.0
			else:
				# Return StickL to its original position when stick is released
				$XboxController/White/StickL.position = stick_l_origin

			# Get right-stick magnitude
			var right_stick_input = Vector2(
				Input.get_axis("look_left", "look_right"),
				Input.get_axis("look_up", "look_down")
			)

			# Apply position based on right-stick magnitude
			if right_stick_input.length() > 0:
				# Move StickR based on stick input strength
				$XboxController/White/StickR.position = stick_r_origin + right_stick_input * 10.0
			else:
				# Return StickR to its original position when stick is released
				$XboxController/White/StickR.position = stick_r_origin


func _on_enable_chat_toggled(toggled_on: bool) -> void:
	player.enable_chat = toggled_on


func _on_enable_crouching_toggled(toggled_on: bool) -> void:
	player.enable_crouching = toggled_on


func _on_enable_double_jump_toggled(toggled_on: bool) -> void:
	player.enable_double_jump = toggled_on


func _on_enable_flying_toggled(toggled_on: bool) -> void:
	player.enable_flying = toggled_on


func _on_enable_jumping_toggled(toggled_on: bool) -> void:
	player.enable_jumping = toggled_on


func _on_enable_kicking_toggled(toggled_on: bool) -> void:
	player.enable_kicking = toggled_on


func _on_enable_punching_toggled(toggled_on: bool) -> void:
	player.enable_punching = toggled_on


func _on_enable_vibration_toggled(toggled_on: bool) -> void:
	player.enable_vibration = toggled_on


func _on_lock_camera_toggled(toggled_on: bool) -> void:
	player.lock_camera = toggled_on


func _on_lock_movement_x_toggled(toggled_on: bool) -> void:
	player.lock_movement_x = toggled_on


func _on_lock_movement_y_toggled(toggled_on: bool) -> void:
	player.lock_movement_y = toggled_on


func _on_lock_perspective_toggled(toggled_on: bool) -> void:
	player.lock_perspective = toggled_on
