extends Control
## debug.gd

# Player (player_3d.gd)
#├── AudioStreamPlayer3D
#├── CameraMount
#│	└── Camera3D (camera_3d.gd)
#│		└── ChatWindow (chat_window.gd)
#│			└── Message (message.gd)
#│		└── Debug (debug.gd)
#│		└── Emotes (emotes.gd)
#│		└── Pause (pause.gd)
#│		└── Settings (settings.gd)
#├── CollisionShape3D
#├── Controls (controls.gd)
#├── ShapeCast3D
#├── States
#└── Visuals
#	└── AuxScene
#		└── AnimationPlayer

# Note: `@onready` variables are set when the scene is loaded.
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:
	# [debug] button _pressed_
	if event.is_action_pressed("debug"):
		# Toggle "debug" visibility
		visible = !visible


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
		$Panel1/IsShimmying.button_pressed = player.is_shimmying
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
		$Panel2/EnableSprinting.button_pressed = player.enable_sprinting
		$Panel2/EnableVibration.button_pressed = player.enable_vibration
		$Panel2/LockCamera.button_pressed = player.lock_camera
		$Panel2/LockMovementX.button_pressed = player.lock_movement_x
		$Panel2/LockMovementY.button_pressed = player.lock_movement_y
		$Panel2/LockPerspective.button_pressed = player.lock_perspective
		$Panel2/GamePaused.button_pressed = player.game_paused

		# Panel 3
		$FPS/Label.text = "FPS: " + str(int(Engine.get_frames_per_second()))


## Called when the "enable_chat" toggle option is changed.
func _on_enable_chat_toggled(toggled_on: bool) -> void:
	player.enable_chat = toggled_on


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
