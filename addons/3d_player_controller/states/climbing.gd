extends Node

@onready var player = Globals.get_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if player.is_climbing:
		print("climbing")
