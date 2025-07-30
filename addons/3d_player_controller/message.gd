class_name Message
extends PanelContainer

const HIDE_DELAY: float = 30.0

# Note: `@onready` variables are set when the scene is loaded.
@onready var content_label: RichTextLabel = %ContentLabel
@onready var hide_timer: Timer = %HideTimer
@onready var sender_label: RichTextLabel = %SenderLabel


## Called when the node enters the scene tree for the first time.
func _ready():
	# Clear the contents
	sender_label.text = ""
	content_label.text = ""


## Called when the "HideTimer" times out.
func _on_hide_timer_timeout() -> void:
	# Hide the message
	hide()


## Sets the message content and sender, and starts the hide timer.
func set_message(sender: String, content: String) -> void:
	# Set the content
	sender_label.text = sender
	content_label.text = content

	# Start the hide timer when message is set
	hide_timer.start(HIDE_DELAY)

	# Ensure message is visible when first set
	show()
