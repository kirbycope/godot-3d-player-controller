extends Node3D

var player: CharacterBody3D


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if player is set
	if player != null:
		# (D-Down)/[Q] _pressed_ (and holding a rifle) -> drop the rifle
		if event.is_action_pressed("button_13"):
			# Get the item
			var item = player.bone_attachement_right_hand.get_children()[0]
			# Remove the item from the player
			player.bone_attachement_right_hand.remove_child(item)
			# Reparent the item from the player to current scene
			player.get_tree().current_scene.add_child(item)
			# Reset player properties
			player.is_holding_tool = false
			player = null


## Called when a node enters the area.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Check if the player is not skateboarding
		if !body.is_skateboarding:
			# Reparent the held item (if any)
			body.reparent_held_item()
			# Flag the player as "holding tool"
			body.is_holding_tool = true
			# Load the scene
			var scene = load("res://scenes/foam_sword.tscn")
			# Instantiate the scene
			var instance = scene.instantiate()
			# Disable the item's "pickup" collision
			instance.get_node("Area3D/CollisionShape3D").disabled = true
			# Add the instance to the player scene
			body.bone_attachement_right_hand.add_child(instance)
			# Reset the transform to avoid position offset issues
			instance.transform = Transform3D.IDENTITY
			# Save the player to the instance
			instance.player = body
			# Remove _this_ instance
			queue_free()
