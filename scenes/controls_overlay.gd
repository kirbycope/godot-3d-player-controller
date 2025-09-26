extends CanvasLayer

@onready var player: CharacterBody3D = get_parent().get_node("Player")

@onready var controls_bottom_left: Control = player.get_node("Controls/VirtualButtons/VirtualButtonsBottomLeft")
@onready var emotes: Control = player.get_node("CameraMount/Camera3D/Emotes")
@onready var label_dpad_down: Label = controls_bottom_left.get_node("TouchScreenButtonDown/Label")
@onready var label_dpad_left: Label = controls_bottom_left.get_node("TouchScreenButtonLeft/Label")
@onready var label_dpad_right: Label = controls_bottom_left.get_node("TouchScreenButtonRight/Label")
@onready var label_dpad_up: Label = controls_bottom_left.get_node("TouchScreenButtonUp/Label")
@onready var label_select: Label = controls_bottom_left.get_node("TouchScreenButtonSelect/Label")
@onready var label_button_l: Label = controls_bottom_left.get_node("TouchScreenButtonL/Label")

@onready var controls_bottom_right: Control = player.get_node("Controls/VirtualButtons/VirtualButtonsBottomRight")
@onready var label_button_a: Label = controls_bottom_right.get_node("TouchScreenButtonA/Label")
@onready var label_button_b: Label = controls_bottom_right.get_node("TouchScreenButtonB/Label")
@onready var label_button_x: Label = controls_bottom_right.get_node("TouchScreenButtonX/Label")
@onready var label_button_y: Label = controls_bottom_right.get_node("TouchScreenButtonY/Label")
@onready var label_button_start: Label = controls_bottom_right.get_node("TouchScreenButtonStart/Label")
@onready var label_button_r: Label = controls_bottom_right.get_node("TouchScreenButtonR/Label")

@onready var controls_top_left: Control = player.get_node("Controls/VirtualButtons/VirtualButtonsTopLeft")
@onready var label_l1: Label = controls_top_left.get_node("TouchScreenButtonL1/Label")
@onready var label_l2: Label = controls_top_left.get_node("TouchScreenButtonL2/Label")

@onready var controls_top_right: Control = player.get_node("Controls/VirtualButtons/VirtualButtonsTopRight")
@onready var label_r1: Label = controls_top_right.get_node("TouchScreenButtonR1/Label")
@onready var label_r2: Label = controls_top_right.get_node("TouchScreenButtonR2/Label")


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_dpad_down.text = "Drop"
	label_dpad_left.text = "Emotes"
	label_dpad_right.text = "Chat"
	label_dpad_up.text = ""

	label_select.text = "View"
	label_button_start.text = "Pause"

	label_button_l.text = "Zoom-Out"
	label_button_r.text = "Zoom-In"

	label_button_a.text = "Jump"
	label_button_b.text = "Sprint"
	label_button_x.text = "Interact"
	label_button_y.text = "Crouch"

	label_l1.text = "L-Punch"
	label_l2.text = "L-Kick"

	label_r1.text = "R-Punch"
	label_r2.text = "R-Kick"


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player.debug_menu:
		visible = !player.debug_menu.visible

	$Climbing.visible = player.is_climbing
	$Crawling.visible = player.is_crawling
	$Driving.visible = player.is_driving
	$Falling.visible = player.is_falling
	$Fishing.visible = player.is_holding_fishing_rod
	$Flying.visible = player.is_flying
	$Hanging.visible = player.is_hanging
	$Holding.visible = player.is_holding and !player.is_rotating_object
	$ItemEquipped.visible = (player.bone_attachment_left_foot.get_children().size() > 0) or (player.bone_attachment_right_foot.get_children().size() > 0)
	$Jumping.visible = player.is_jumping
	if player.enable_double_jump and !player.is_double_jumping:
		$Jumping.text = "(A) | [Space]       Double-Jump"
	if player.enable_flying and !player.is_flying:
		$Jumping.text = "(A) | [Space]               Fly"
	$Paragliding.visible = player.is_paragliding
	$Rifling.visible = player.is_holding_rifle
	$Rotating.visible = player.is_rotating_object
	$Skateboarding.visible = player.is_skateboarding
	$Sprinting.visible = player.is_sprinting
	$Standing.visible = player.is_standing
	$Swimming.visible = player.is_swimming
	$ToolEquipped.visible = player.is_holding_tool
	$Unarmed.visible = !player.is_holding_fishing_rod and !player.is_holding and !player.is_holding_rifle and !player.is_holding_tool 
	$Walking.visible = player.is_walking or player.is_running

	if emotes.visible:
		label_dpad_down.text = "Bow"
		label_dpad_left.text = "Clap"
		label_dpad_right.text = "Cry"
		label_dpad_up.text = "Wave"
	else:
		label_dpad_down.text = "Drop"
		label_dpad_left.text = "Emotes"
		label_dpad_right.text = "Chat"
		label_dpad_up.text = ""
	
	if player.perspective == 1:
		label_button_l.get_parent().hide()
		label_button_r.get_parent().hide()
	else:
		label_button_l.get_parent().show()
		label_button_r.get_parent().show()
