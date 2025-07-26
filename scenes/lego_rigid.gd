extends RigidBody3D


# Recursively apply color to all mesh nodes
func apply_color_to_mesh(node: Node, color: Color) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			if color == Color(0, 0, 0, 0):
				child.material_override = null
			else:
				if child.material_override == null:
					child.material_override = StandardMaterial3D.new()
				child.material_override.albedo_color = color
		apply_color_to_mesh(child, color)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Lego"):
		var color = Color(255, 0, 0, 255)
		apply_color_to_mesh(body, color)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Lego"):
		var color = Color(0, 0, 0, 0)
		apply_color_to_mesh(body, color)
