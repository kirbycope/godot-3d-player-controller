extends Control

@onready var controls = get_parent()

@onready var virtual_buttons_bottom_left: Control = $VirtualButtonsBottomLeft
@onready var label_dpad_down: Label = virtual_buttons_bottom_left.get_node("TouchScreenButtonDown/Label")
@onready var label_dpad_left: Label = virtual_buttons_bottom_left.get_node("TouchScreenButtonLeft/Label")
@onready var label_dpad_right: Label = virtual_buttons_bottom_left.get_node("TouchScreenButtonRight/Label")
@onready var label_dpad_up: Label = virtual_buttons_bottom_left.get_node("TouchScreenButtonUp/Label")
@onready var label_select: Label = virtual_buttons_bottom_left.get_node("TouchScreenButtonSelect/Label")
@onready var label_joystick_l: Label = virtual_buttons_bottom_left.get_node("TouchScreenButtonL/Label")

@onready var virtual_buttons_bottom_right: Control = $VirtualButtonsBottomRight
@onready var label_button_a: Label = virtual_buttons_bottom_right.get_node("TouchScreenButtonA/Label")
@onready var label_button_b: Label = virtual_buttons_bottom_right.get_node("TouchScreenButtonB/Label")
@onready var label_button_x: Label = virtual_buttons_bottom_right.get_node("TouchScreenButtonX/Label")
@onready var label_button_y: Label = virtual_buttons_bottom_right.get_node("TouchScreenButtonY/Label")
@onready var label_button_start: Label = virtual_buttons_bottom_right.get_node("TouchScreenButtonStart/Label")
@onready var label_joystick_r: Label = virtual_buttons_bottom_right.get_node("TouchScreenButtonR/Label")

@onready var virtual_buttons_top_left: Control = $VirtualButtonsTopLeft
@onready var label_l1: Label = virtual_buttons_top_left.get_node("TouchScreenButtonL1/Label")
@onready var label_l2: Label = virtual_buttons_top_left.get_node("TouchScreenButtonL2/Label")

@onready var virtual_buttons_top_right: Control = $VirtualButtonsTopRight
@onready var label_r1: Label = virtual_buttons_top_right.get_node("TouchScreenButtonR1/Label")
@onready var label_r2: Label = virtual_buttons_top_right.get_node("TouchScreenButtonR2/Label")


func _ready() -> void:
	set_labels_to_default()


func clear_labels() -> void:
	label_button_a.text = ""
	label_button_b.text = ""
	label_button_x.text = ""
	label_button_y.text = ""
	label_l1.text = ""
	label_r1.text = ""
	label_l2.text = ""
	label_r2.text = ""
	label_select.text = ""
	label_button_start.text = ""
	label_joystick_l.text = ""
	label_joystick_r.text = ""
	label_dpad_up.text = ""
	label_dpad_down.text = ""
	label_dpad_left.text = ""
	label_dpad_right.text = ""


func set_labels_to_default() -> void:
	label_button_a.text = controls.button_0
	label_button_b.text = controls.button_1
	label_button_x.text = controls.button_2
	label_button_y.text = controls.button_3
	label_l1.text = controls.button_4
	label_r1.text = controls.button_5
	label_l2.text = controls.button_6
	label_r2.text = controls.button_7
	label_select.text = controls.button_8
	label_button_start.text = controls.button_9
	label_joystick_l.text = controls.button_10
	label_joystick_r.text = controls.button_11
	label_dpad_up.text = controls.button_12
	label_dpad_down.text = controls.button_13
	label_dpad_left.text = controls.button_14
	label_dpad_right.text = controls.button_15


func show_labels(toggled_on) -> void:
	if toggled_on:
		set_labels_to_default()
	else:
		clear_labels()
