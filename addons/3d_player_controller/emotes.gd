extends Control

@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:

	# # Check if the [chat] action _pressed_ (and emotes are enabled)
	if event.is_action_pressed("dpad_left") and player.enable_emotes:

		# Toggle visibility
		toggle_visibility()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	visible = false


func _on_emote_1_button_button_down() -> void:
	player.animation_player.play("Waving")
	player.is_animation_locked = true
	toggle_visibility()


func _on_emote_2_button_button_down() -> void:
	player.animation_player.play("Clapping")
	player.is_animation_locked = true
	toggle_visibility()


func _on_emote_3_button_button_down() -> void:
	player.animation_player.play("Crying")
	player.is_animation_locked = true
	toggle_visibility()


func _on_emote_4_button_button_down() -> void:
	player.animation_player.play("Quick_Informal_Bow")
	player.is_animation_locked = true
	toggle_visibility()


## Toggles the Emote menu on/off (including the cursor)
func toggle_visibility() -> void:

	# Toggle visibility
	visible = !visible

	# Toggle mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED)
