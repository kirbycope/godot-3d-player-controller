extends Node

class_name BaseState

@onready var player: CharacterBody3D = get_parent().get_parent()


## Returns the string name of a state.
func get_state_name(state: States.State) -> String:

	# Return the state name with the first letter capitalized
	return States.State.keys()[state].capitalize()


## Called when a state needs to transition to another.
func transition(from_state: String, to_state: String):

	# Get the "from" scene
	var from_scene = get_parent().find_child(from_state)

	# Get the "to scene
	var to_scene = get_parent().find_child(to_state)

	# Check if the scenes exist
	if from_scene and to_scene:

		# Stop processing the "from" scene
		from_scene.stop()

		# Start processing the "to" scene
		to_scene.start()
