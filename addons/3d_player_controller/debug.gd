extends Control

# Note: `@onready` variables are set when the scene is loaded.
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:
	# [debug] button _pressed_
	if event.is_action_pressed("debug"):
		# Toggle "debug" visibility
		visible = !visible

	# [R] key to trigger ragdoll for testing (only when debug panel is visible)
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			# Get the current state name and transition to ragdoll
			var current_state_name = player.base_state.get_state_name(player.current_state)
			# Transition to ragdoll state
			player.base_state.transition(current_state_name, "Ragdoll")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check is the Debug Panel is visible
	if visible:
		# Panel 1
		$Panel1/IsAnimationLocked.button_pressed = player.is_animation_locked
		$Panel1/IsClimbing.button_pressed = player.is_climbing
		$Panel1/IsCrawling.button_pressed = player.is_crawling
		$Panel1/IsCrouching.button_pressed = player.is_crouching
		$Panel1/IsDoubleJumping.button_pressed = player.is_double_jumping
		$Panel1/IsDriving.button_pressed = player.is_driving
		$Panel1/IsFalling.button_pressed = player.is_falling
		$Panel1/IsFlying.button_pressed = player.is_flying
		$Panel1/IsHanging.button_pressed = player.is_hanging
		$Panel1/IsHolding.button_pressed = player.is_holding
		$Panel1/IsJumping.button_pressed = player.is_jumping
		$Panel1/IsKickingLeft.button_pressed = player.is_kicking_left
		$Panel1/IsKickingRight.button_pressed = player.is_kicking_right
		$Panel1/IsParagliding.button_pressed = player.is_paragliding
		$Panel1/IsPunchingLeft.button_pressed = player.is_punching_left
		$Panel1/IsPunchingRight.button_pressed = player.is_punching_right
		$Panel1/IsPushing.button_pressed = player.is_pushing
		$Panel1/IsRunning.button_pressed = player.is_running
		$Panel1/IsSkateboarding.button_pressed = player.is_skateboarding
		$Panel1/IsShimmying.button_pressed = player.is_shimmying
		$Panel1/IsSprinting.button_pressed = player.is_sprinting
		$Panel1/IsStanding.button_pressed = player.is_standing
		$Panel1/IsSwimming.button_pressed = player.is_swimming
		$Panel1/IsUsing.button_pressed = player.is_using
		$Panel1/IsWalking.button_pressed = player.is_walking
		# Panel 1 - Fishing
		$Panel1/Fishing/IsHoldingFishingRod.button_pressed = player.is_holding_fishing_rod
		$Panel1/Fishing/IsCasting.button_pressed = player.is_casting
		$Panel1/Fishing/IsReeling.button_pressed = player.is_reeling
		# Panel 1 - Shooting
		$Panel1/Shooting/IsHoldingRifle.button_pressed = player.is_holding_rifle
		$Panel1/Shooting/IsAiming.button_pressed = player.is_aiming
		$Panel1/Shooting/IsFiring.button_pressed = player.is_firing
		# Panel 2 - Swinging
		$Panel1/Swinging/IsHoldingTool.button_pressed = player.is_holding_tool
		$Panel1/Swinging/IsBlockingLeft.button_pressed = player.is_blocking_left
		$Panel1/Swinging/IsBlockingRight.button_pressed = player.is_blocking_right
		$Panel1/Swinging/IsSwingingLeft.button_pressed = player.is_swinging_left
		$Panel1/Swinging/IsSwingingRight.button_pressed = player.is_swinging_right
		# Panel 2
		$Panel2/EnableCrouching.button_pressed = player.enable_crouching
		$Panel2/EnableClimbing.button_pressed = player.enable_climbing
		$Panel2/EnableChat.button_pressed = player.enable_chat
		$Panel2/EnableDoubleJump.button_pressed = player.enable_double_jump
		$Panel2/EnableFlying.button_pressed = player.enable_flying
		$Panel2/EnableJumping.button_pressed = player.enable_jumping
		$Panel2/EnableKicking.button_pressed = player.enable_kicking
		$Panel2/EnableParagliding.button_pressed = player.enable_paragliding
		$Panel2/EnablePunching.button_pressed = player.enable_punching
		$Panel2/EnableSprinting.button_pressed = player.enable_sprinting
		$Panel2/EnableVibration.button_pressed = player.enable_vibration
		$Panel2/LockCamera.button_pressed = player.lock_camera
		$Panel2/LockMovementX.button_pressed = player.lock_movement_x
		$Panel2/LockMovementY.button_pressed = player.lock_movement_y
		$Panel2/LockPerspective.button_pressed = player.lock_perspective
		$Panel2/GamePaused.button_pressed = player.game_paused

		# Panel 3
		$Coordinates.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.global_position.x, player.global_position.y, player.global_position.z]
		$Velocity.text = "[center][color=red]X:[/color]%.1f [color=green]Y:[/color]%.1f [color=blue]Z:[/color]%.1f[/center]" % [player.velocity.x, player.velocity.y, player.velocity.z]
		$FPS.text = "FPS: " + str(int(Engine.get_frames_per_second()))


## Called when the "enable_chat" toggle option is changed.
func _on_enable_chat_toggled(toggled_on: bool) -> void:
	player.enable_chat = toggled_on


## Called when the "enable_climbing" toggle option is changed.
func _on_enable_climbing_toggled(toggled_on: bool) -> void:
	player.enable_climbing = toggled_on


## Called when the "enable_crouching" toggle option is changed.
func _on_enable_crouching_toggled(toggled_on: bool) -> void:
	player.enable_crouching = toggled_on


## Called when the "enable_double_jump" toggle option is changed.
func _on_enable_double_jump_toggled(toggled_on: bool) -> void:
	player.enable_double_jump = toggled_on


## Called when the "enable_flying" toggle option is changed.
func _on_enable_flying_toggled(toggled_on: bool) -> void:
	player.enable_flying = toggled_on


## Called when the "enable_jumping" toggle option is changed.
func _on_enable_jumping_toggled(toggled_on: bool) -> void:
	player.enable_jumping = toggled_on


## Called when the "enable_kicking" toggle option is changed.
func _on_enable_kicking_toggled(toggled_on: bool) -> void:
	player.enable_kicking = toggled_on


func _on_enable_paragliding_toggled(toggled_on: bool) -> void:
	player.enable_paragliding = toggled_on


## Called when the "enable_punching" toggle option is changed.
func _on_enable_punching_toggled(toggled_on: bool) -> void:
	player.enable_punching = toggled_on


## Called when the "enable_sprinting" toggle option is changed.
func _on_enable_sprinting_toggled(toggled_on: bool) -> void:
	player.enable_sprinting = toggled_on


## Called when the "enable_vibration" toggle option is changed.
func _on_enable_vibration_toggled(toggled_on: bool) -> void:
	player.enable_vibration = toggled_on


## Called when the "locak_camera" toggle option is changed.
func _on_lock_camera_toggled(toggled_on: bool) -> void:
	player.lock_camera = toggled_on


## Called when the "lock_movement_x" toggle option is changed.
func _on_lock_movement_x_toggled(toggled_on: bool) -> void:
	player.lock_movement_x = toggled_on


## Called when the "lock_movement_y" toggle option is changed.
func _on_lock_movement_y_toggled(toggled_on: bool) -> void:
	player.lock_movement_y = toggled_on


## Called when the "lock_perspective" toggle option is changed.
func _on_lock_perspective_toggled(toggled_on: bool) -> void:
	player.lock_perspective = toggled_on
