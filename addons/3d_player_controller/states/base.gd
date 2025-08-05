class_name BaseState
extends Node

const STATES = preload("res://addons/3d_player_controller/states/states.gd")

# Note: `@onready` variables are set when the scene is loaded.
@onready var player: CharacterBody3D = get_parent().get_parent() ## The player character.
@onready var controls = player.get_node("Controls") ## The `virtual_controller` addon node.


## Draws a debug sphere at the specified position and with the specified color.
func draw_debug_sphere(pos: Vector3, color: Color) -> void:
	# Create a new mesh instance for the debug sphere
	var debug_sphere = MeshInstance3D.new()
	# Add the debug sphere to the scene tree
	player.get_tree().get_root().add_child(debug_sphere)
	# Create a visual sphere mesh
	var sphere_mesh = SphereMesh.new()
	# Set the radius of the sphere mesh
	sphere_mesh.radius = 0.1
	# Set the height of the sphere mesh
	sphere_mesh.height = 0.2
	# Add the visual mesh to the debug sphere's "mesh"property
	debug_sphere.mesh = sphere_mesh
	# Create a new material for the debug sphere
	var material = StandardMaterial3D.new()
	# Set the albedo color of the material to the specified color
	material.albedo_color = color
	# Add the material to the debug sphere's "material_override"
	debug_sphere.material_override = material
	debug_sphere.global_position = pos


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
