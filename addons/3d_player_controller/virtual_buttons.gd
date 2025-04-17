extends Control


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Connect to the input type changed signal
	Controls.input_type_changed.connect(_on_input_type_changed)

	# Set initial visibility based on current input type
	_on_input_type_changed(Controls.current_input_type)


## Called when the input type changes.
func _on_input_type_changed(input_type: Controls.InputType) -> void:

	# Set the visibility of the virtual buttons based on the input type
	$"..".visible = (input_type == Controls.InputType.TOUCH)
