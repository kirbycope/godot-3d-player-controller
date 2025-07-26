extends Node3D

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply initial color
	var color = Color(randf(), randf(), randf()) # Generate a random color
	apply_color_to_csg(self, color)

# Called every 20 seconds by the timer
func _on_timer_timeout() -> void:
	var color = Color(randf(), randf(), randf()) # Generate a random color
	apply_color_to_csg(self, color)


# Recursively apply color to all CSG and Mesh nodes
func apply_color_to_csg(node: Node, color: Color) -> void:
	for child in node.get_children():
		if child is CSGShape3D:
			if child.material == null:
				child.material = StandardMaterial3D.new()
			child.material.albedo_color = color
		elif child is MeshInstance3D:
			if child.material_override == null:
				child.material_override = StandardMaterial3D.new()
			child.material_override.albedo_color = color
		apply_color_to_csg(child, color)
