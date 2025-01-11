extends Control


func _ready() -> void:
	top_level = true


func _process(_delta: float) -> void:

	if Controls.current_input_type == Controls.InputType.CONTROLLER:
		visible = false

	elif Controls.current_input_type == Controls.InputType.MOUSE_KEYBOARD:
		visible = false

	elif Controls.current_input_type == Controls.InputType.TOUCH:
		visible = true


func _on_texture_button_a_button_down() -> void:
	Input.action_press("jump")


func _on_texture_button_a_button_up() -> void:
	Input.action_release("jump")


func _on_texture_button_b_button_down() -> void:
	Input.action_press("sprint")


func _on_texture_button_b_button_up() -> void:
	Input.action_release("sprint")


func _on_texture_button_x_button_down() -> void:
	Input.action_press("use")


func _on_texture_button_x_button_up() -> void:
	Input.action_release("use")


func _on_texture_button_y_button_down() -> void:
	Input.action_press("crouch")


func _on_texture_button_y_button_up() -> void:
	Input.action_release("crouch")
