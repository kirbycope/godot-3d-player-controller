extends Node3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Disable the mouse pointer and capture the motion
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Make sure the game is unpaused
	Globals.game_paused = false

	# Align visuals with the camera
	$Player3D/Visuals.rotation = Vector3(0.0, 0.0, $Player3D/CameraMount.rotation.z)
