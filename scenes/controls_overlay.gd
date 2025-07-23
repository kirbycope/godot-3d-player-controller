extends CanvasLayer

@onready var player = get_parent().get_node("Player")
@onready var controls_bottom_left = player.get_node("Controls/VirtualButtons/VirtualButtonsBottomLeft")
@onready var emotes = player.get_node("CameraMount/Camera3D/Emotes")
@onready var label_dpad_down = controls_bottom_left.get_node("TouchScreenButtonDown/Label")
@onready var label_dpad_left = controls_bottom_left.get_node("TouchScreenButtonLeft/Label")
@onready var label_dpad_right = controls_bottom_left.get_node("TouchScreenButtonRight/Label")
@onready var label_dpad_up = controls_bottom_left.get_node("TouchScreenButtonUp/Label")


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Climbing.visible = player.is_climbing
	$Driving.visible = player.is_driving
	$Fishing.visible = player.is_holding_fishing_rod
	$Flying.visible = player.is_flying
	$Hanging.visible = player.is_hanging
	$Holding.visible = player.is_holding
	$Rifling.visible = player.is_holding_rifle
	$Skateboarding.visible = player.is_skateboarding
	$Swimming.visible = player.is_swimming

	if emotes.visible:
		label_dpad_down.text = "Bow"
		label_dpad_left.text = "Clap"
		label_dpad_right.text = "Cry"
		label_dpad_up.text = "Wave"
	else:
		label_dpad_down.text = ""
		label_dpad_left.text = "Emotes"
		label_dpad_right.text = "Chat"
		label_dpad_up.text = ""
