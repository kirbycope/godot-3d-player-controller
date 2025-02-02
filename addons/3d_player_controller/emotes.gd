extends Control

@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:

	# # Check if the [chat] action _pressed_ (and emotes are enabled)
	if event.is_action_pressed("dpad_left") and player.enable_emotes:

		# Toggle visibility
		visible = !visible
		
		# Toggle mouse capture
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED)


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	visible = false
