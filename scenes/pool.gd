extends Node3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Get the pool of water
	var area_node = $MeshInstance3D/Area3D

	# Connect body entered function and bind the Area3D as a parameter
	area_node.body_entered.connect(_on_area_3d_body_entered.bind(area_node))

	# Connect body exited function
	area_node.body_exited.connect(_on_area_3d_body_exited)


func _on_area_3d_body_entered(body: Node3D, area_node: Node3D) -> void:

	# Check if the collision body is a character
	if body is CharacterBody3D:

		# Store which body the player is swimming in
		body.swimming_in = area_node

		# Get the string name of the player's current state
		var current_state = body.base_state.get_state_name(body.current_state)

		# Start "swimming"
		body.base_state.transition(current_state, "Swimming")


func _on_area_3d_body_exited(body: Node3D) -> void:

	# Check if the collision body is a character
	if body is CharacterBody3D:

		# Stop "swimming"
		body.base_state.transition("Swimming", "Standing")
