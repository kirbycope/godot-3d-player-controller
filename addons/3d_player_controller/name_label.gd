extends Label3D

@onready var player = get_parent()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set player nameplate
	text = str(player.get_username())


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Hide nameplate if alone
	if multiplayer.get_peers().size() == 0:
		hide()
	else:
		show()
