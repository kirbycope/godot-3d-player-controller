extends Control

@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:

	# Check if the game is not paused
	if !player.game_paused:

		# Check if emotes are enabled
		if player.enable_emotes:

			# Check if the control is visible
			if visible:

				# Check if the menu was opened using controller based input
				if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT):

					# Show the dpad emote controls
					$DPad.visible = true

					# Hide the keyboard emote controls
					$Keyboard.visible = false

				# Check if the menu was opened using keyboard based input
				elif Input.is_key_pressed(KEY_B):

					# Hide the dpad emote controls
					$DPad.visible = false

					# Show the keyboard emote controls
					$Keyboard.visible = true

				# Check if the [start] action _pressed_
				if event.is_action_pressed("start"):

					# Hide the emote menu
					visible = false

				# Check if the [dpad_down] action _pressed_
				if event.is_action_pressed("dpad_down"):

					# Perform emote 4
					emote4()

				# Check if the [dpad_left] action _pressed_
				if event.is_action_pressed("dpad_left"):

					# Perform emote 2
					emote2()

				# Check if the [dpad_right] action _pressed_
				if event.is_action_pressed("dpad_right"):

					# Perform emote 3
					emote3()

				# Check if the [dpad_up] action _pressed_
				if event.is_action_pressed("dpad_up"):

					# Perform emote 1
					emote1()

			# The control must not be visible
			else:

				# Check if the [dpad_left] action _pressed_
				if event.is_action_pressed("dpad_left"):

					# Toggle visibility
					toggle_visibility()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Hide the emote menu
	visible = false

	# Hide the dpad emote controls
	$DPad.visible = false

	# Hide the keyboard emote controls
	$Keyboard.visible = false


## Called when the emote 1 button is pressed.
func _on_emote_1_button_button_down() -> void:

	# Perform emote 1
	emote1()


## Called when the emote 2 button is pressed.
func _on_emote_2_button_button_down() -> void:

	# Perform emote 2
	emote2()


## Called when the emote 3 button is pressed.
func _on_emote_3_button_button_down() -> void:

	# Perform emote 3
	emote3()


## Called when the emote 4 button is pressed.
func _on_emote_4_button_button_down() -> void:

	# Perform emote 4
	emote4()


## Performs emote 1.
func emote1() -> void:

	# Play the "waving" animation
	player.animation_player.play("Waving")

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Toggle the emote menu's visibility
	toggle_visibility()


## Performs emote 2.
func emote2() -> void:

	# Play the "clapping" animation
	player.animation_player.play("Clapping")

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Toggle the emote menu's visibility
	toggle_visibility()


## Performs emote 3.
func emote3() -> void:

	# Play the "crying" animation
	player.animation_player.play("Crying")

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Toggle the emote menu's visibility
	toggle_visibility()


## Performs emote 4.
func emote4() -> void:

	# Play the "bowing" animation
	player.animation_player.play("Quick_Informal_Bow")

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Toggle the emote menu's visibility
	toggle_visibility()


## Toggles the Emote menu on/off (including the cursor).
func toggle_visibility() -> void:

	# Toggle visibility
	visible = !visible

	# Toggle mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED)
