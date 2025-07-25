extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color = Color(randf(), randf(), randf()) # Generate a random color
	apply_color_to_csg(self, color)


# Recursively apply color to all CSG nodes
func apply_color_to_csg(node: Node, color: Color) -> void:
	for child in node.get_children():
		if child is CSGShape3D:
			if child.material == null:
				child.material = StandardMaterial3D.new()
			child.material.albedo_color = color
		apply_color_to_csg(child, color)
