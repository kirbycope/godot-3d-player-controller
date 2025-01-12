extends Node2D


func _process(_delta: float) -> void:
	if Controls.current_input_type == Controls.InputType.CONTROLLER:
		visible = false
	elif Controls.current_input_type == Controls.InputType.MOUSE_KEYBOARD:
		visible = false
	elif Controls.current_input_type == Controls.InputType.TOUCH:
		visible = true
