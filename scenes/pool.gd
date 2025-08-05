extends Node3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Get the pool of water
	var area_node = $MeshInstance3D/Area3D

	# Connect body entered function and bind the Area3D as a parameter
	area_node.body_entered.connect(_on_area_3d_body_entered.bind(area_node))

	# Connect body exited function
	area_node.body_exited.connect(_on_area_3d_body_exited)


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D, area_node: Node3D) -> void:

	# Check if the collision body is a character
	if body is CharacterBody3D and body.is_in_group("Player"):

		# Drop any equipment before swimming
		if body.is_skateboarding:
			# Remove any foot mounted equipment from the player
			body.visuals.get_node("FootMount").remove_child(body.is_skateboarding_on)
			# Reparent the skateboard to the main scene
			get_tree().current_scene.add_child(body.is_skateboarding_on)
			body.is_skateboarding_on = null

		# Store which body the player is swimming in
		body.is_swimming_in = area_node

		# Get the string name of the player's current state
		var current_state = body.base_state.get_state_name(body.current_state)

		# Start "swimming"
		body.base_state.transition(current_state, "Swimming")


## Called when a Node3D exits the Area3D.
func _on_area_3d_body_exited(body: Node3D) -> void:

	# Check if the collision body is a character
	if body is CharacterBody3D and body.is_in_group("Player"):

		# Stop "swimming"
		body.base_state.transition("Swimming", "Standing")
