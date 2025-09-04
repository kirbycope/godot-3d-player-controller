extends Label3D

@onready var player = get_parent()


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Hide nameplate if alone
	if multiplayer.get_peers().size() == 0:
		hide()
	else:
		# Set player nameplate
		text = str(player.get_username())
		show()
