class_name BaseState
extends Node
## base.gd

# States (states.gd)
#├── Base (base.gd)
#├── Climbing (climbing.gd)
#├── Crawling (crawling.gd)
#├── Crouching (crouching.gd)
#├── Driving (driving.gd)
#├── Falling (falling.gd)
#├── Flying (flying.gd)
#├── Hanging (hanging.gd)
#├── Holding (holding.gd)
#├── Jumping (jumping.gd)
#├── Running (running.gd)
#├── Skateboarding (skateboarding.gd)
#├── Sprinting (sprinting.gd)
#├── Standing (standing.gd)
#├── Swimming (swimming.gd)
#└── Walking (walking.gd)

const STATES = preload("res://addons/3d_player_controller/states/states.gd")

# Note: `@onready` variables are set when the scene is loaded.
@onready var player: CharacterBody3D = get_parent().get_parent()


## Returns the string name of a state.
func get_state_name(state: STATES.State) -> String:
	# Return the state name with the first letter capitalized
	return STATES.State.keys()[state].capitalize()


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
