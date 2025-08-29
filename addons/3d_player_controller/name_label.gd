extends Label3D

@onready var player = get_parent()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set playername
	text = str(player.get_username())
	# Hide if alone
	if multiplayer.get_peers().size() == 0:
		hide()
