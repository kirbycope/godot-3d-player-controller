extends Node

@onready var player = Globals.get_player()


## Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# Check if the animation player is not locked
		if player.is_animation_locked:
			pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is "hanging"
	if player.is_hanging:

		# Set the player's movement speed
		player.current_speed = player.speed_hanging
