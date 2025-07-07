extends PanelContainer

class_name Message

const HIDE_DELAY: float = 30.0

@onready var content_label: Label = %ContentLabel
@onready var hide_timer: Timer = %HideTimer
@onready var sender_label: Label = %SenderLabel


## Called when the node enters the scene tree for the first time.
func _ready():
	# Clear the contents
	sender_label.text = ""
	content_label.text = ""


func _on_hide_timer_timeout() -> void:
	# Hide the message
	hide()


func set_message(sender: String, content: String) -> void:
	# Set the content
	sender_label.text = sender
	content_label.text = content

	# Start the hide timer when message is set
	hide_timer.start(HIDE_DELAY)

	# Ensure message is visible when first set
	show()
