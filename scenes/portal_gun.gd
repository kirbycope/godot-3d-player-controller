extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Check if the player is not skateboarding
		if !body.is_skateboarding:
			# Reparent the held item (if any)
			body.get_parent().reparent_held_item()
			# Flag the player as "holding rifle"
			body.is_holding_rifle = true
			# Load the scene
			var scene = load("res://scenes/portal_gun.tscn")
			# Instantiate the scene
			var instance = scene.instantiate()
			# Disable the portal gun's "pickup" collision
			instance.get_node("Area3D/CollisionShape3D").disabled = true
			# Add the instance to the player scene
			body.visuals.get_node("HeldItemMount").add_child(instance)
			# Save the portal gun instance to the player
			body.is_holding_onto = instance
			# Remove _this_ instance
			queue_free()
