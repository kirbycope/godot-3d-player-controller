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

				# Check if the [start] action _pressed_
				if event.is_action_pressed("start"):
					visible = false

				# Check if the [dpad_down] action _pressed_
				if event.is_action_pressed("dpad_down"):
					emote4()

				# Check if the [dpad_left] action _pressed_
				if event.is_action_pressed("dpad_left"):
					emote2()

				# Check if the [dpad_right] action _pressed_
				if event.is_action_pressed("dpad_right"):
					emote3()

				# Check if the [dpad_up] action _pressed_
				if event.is_action_pressed("dpad_up"):
					emote1()

			# The control must not be visible
			else:

				# Check if the [dpad_left] action _pressed_
				if event.is_action_pressed("dpad_left"):

					# Toggle visibility
					toggle_visibility()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	visible = false


func _on_emote_1_button_button_down() -> void:
	emote1()


func _on_emote_2_button_button_down() -> void:
	emote2()


func _on_emote_3_button_button_down() -> void:
	emote3()


func _on_emote_4_button_button_down() -> void:
	emote4()


func emote1() -> void:
	player.animation_player.play("Waving")
	player.is_animation_locked = true
	toggle_visibility()


func emote2() -> void:
	player.animation_player.play("Clapping")
	player.is_animation_locked = true
	toggle_visibility()


func emote3() -> void:
	player.animation_player.play("Crying")
	player.is_animation_locked = true
	toggle_visibility()


func emote4() -> void:
	player.animation_player.play("Quick_Informal_Bow")
	player.is_animation_locked = true
	toggle_visibility()


## Toggles the Emote menu on/off (including the cursor)
func toggle_visibility() -> void:

	# Toggle visibility
	visible = !visible

	# Toggle mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED)
