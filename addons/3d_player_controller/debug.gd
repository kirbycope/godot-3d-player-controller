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
		$Panel1/IsAiming.button_pressed = $"../../..".is_aiming
		$Panel1/IsAnimationLocked.button_pressed = $"../../..".is_animation_locked
		$Panel1/IsCasting.button_pressed = $"../../..".is_casting
		$Panel1/IsClimbing.button_pressed = $"../../..".is_climbing
		$Panel1/IsCrawling.button_pressed = $"../../..".is_crawling
		$Panel1/IsCrouching.button_pressed = $"../../..".is_crouching
		$Panel1/IsDoubleJumping.button_pressed = $"../../..".is_double_jumping
		$Panel1/IsDriving.button_pressed = $"../../..".is_driving
		$Panel1/IsFalling.button_pressed = $"../../..".is_falling
		$Panel1/IsFiring.button_pressed = $"../../..".is_firing
		$Panel1/IsFlying.button_pressed = $"../../..".is_flying
		$Panel1/IsGrounded.button_pressed = $"../../..".is_grounded
		$Panel1/IsHanging.button_pressed = $"../../..".is_hanging
		$Panel1/IsHolding.button_pressed = $"../../..".is_holding
		$Panel1/IsHoldingFishingRod.button_pressed = $"../../..".is_holding_fishing_rod
		$Panel1/IsHoldingRifle.button_pressed = $"../../..".is_holding_rifle
		$Panel1/IsHoldingTool.button_pressed = $"../../..".is_holding_tool
		$Panel1/IsJumping.button_pressed = $"../../..".is_jumping
		$Panel1/IsKickingLeft.button_pressed = $"../../..".is_kicking_left
		$Panel1/IsKickingRight.button_pressed = $"../../..".is_kicking_right
		$Panel1/IsPunchingLeft.button_pressed = $"../../..".is_punching_left
		$Panel1/IsPunchingRight.button_pressed = $"../../..".is_punching_right
		$Panel1/IsReeling.button_pressed = $"../../..".is_reeling
		$Panel1/IsRunning.button_pressed = $"../../..".is_running
		$Panel1/IsSkateboarding.button_pressed = $"../../..".is_skateboarding
		$Panel1/IsSprinting.button_pressed = $"../../..".is_sprinting
		$Panel1/IsStanding.button_pressed = $"../../..".is_standing
		$Panel1/IsSwimming.button_pressed = $"../../..".is_swimming
		$Panel1/IsWalking.button_pressed = $"../../..".is_walking

		# Panel 2
		$Panel2/EnableCrouching.button_pressed = $"../../..".enable_crouching
		$Panel2/EnableChat.button_pressed = $"../../..".enable_chat
		$Panel2/EnableDoubleJump.button_pressed = $"../../..".enable_double_jump
		$Panel2/EnableFlying.button_pressed = $"../../..".enable_flying
		$Panel2/EnableJumping.button_pressed = $"../../..".enable_jumping
		$Panel2/EnableKicking.button_pressed = $"../../..".enable_kicking
		$Panel2/EnablePunching.button_pressed = $"../../..".enable_punching
		$Panel2/EnableVibration.button_pressed = $"../../..".enable_vibration
		$Panel2/LockCamera.button_pressed = $"../../..".lock_camera
		$Panel2/LockMovementX.button_pressed = $"../../..".lock_movement_x
		$Panel2/LockMovementY.button_pressed = $"../../..".lock_movement_y
		$Panel2/LockPerspective.button_pressed = $"../../..".lock_perspective
		$Panel2/GamePaused.button_pressed = player.game_paused

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
