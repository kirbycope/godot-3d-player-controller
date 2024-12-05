extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is "climbing"
	if player.is_climbing:

		#print("climbing")
		pass
