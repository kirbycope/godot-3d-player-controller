class_name Message
extends PanelContainer
## message.gd

# Player (player_3d.gd)
#├── AudioStreamPlayer3D
#├── CameraMount
#│	└── Camera3D (camera_3d.gd)
#│		└── ChatWindow (chat_window.gd)
#│			└── Message (message.gd)
#│		└── Debug (debug.gd)
#│		└── Emotes (emotes.gd)
#│		└── Pause (pause.gd)
#│		└── Settings (settings.gd)
#├── CollisionShape3D
#├── Controls (controls.gd)
#├── ShapeCast3D
#├── States (states.gd)
#└── Visuals
#│	└── AuxScene
#│		└── AnimationPlayer

const HIDE_DELAY: float = 30.0

# Note: `@onready` variables are set when the scene is loaded.
@onready var content_label: Label = %ContentLabel
@onready var hide_timer: Timer = %HideTimer
@onready var sender_label: Label = %SenderLabel


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
