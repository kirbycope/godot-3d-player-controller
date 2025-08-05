extends Node3D

var initial_jump_velocity: float
var initial_shoe_position: Vector3
var initial_shoe_rotation: Vector3
var initial_shoe_2_position: Vector3
var initial_shoe_2_rotation: Vector3
var player: CharacterBody3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var shoe: Node3D = $Shoe
@onready var shoe_2: Node3D = $Shoe2


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_shoe_position = shoe.position
	initial_shoe_rotation = shoe.rotation
	initial_shoe_2_position = shoe_2.position
	initial_shoe_2_rotation = shoe_2.rotation


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event: InputEvent) -> void:
	# Check if player is set
	if player != null:
		# [button_0] "jump" button pressed
		if event.is_action_pressed("button_0"):
			if player.is_on_floor():
				audio_stream_player_3d.play()

		# [button_13] "drop" button pressed
		elif event.is_action_released("button_13"):
			# Get the equipped items from both feet
			var left_foot_children = player.bone_attachement_left_foot.get_children()
			var right_foot_children = player.bone_attachement_right_foot.get_children()
			# Create a new complete moon shoes instance to drop
			var scene = load("res://scenes/moon_shoes.tscn")
			var dropped_item = scene.instantiate()
			# Add the complete item to the current scene first
			player.get_tree().current_scene.add_child(dropped_item)
			# Now position the dropped item at position 0, 0, 0
			dropped_item.global_position = Vector3.ZERO
			# Remove the equipped items from both feet
			for child in left_foot_children:
				if child.name == "MoonShoes":
					child.queue_free()
			for child in right_foot_children:
				if child.name == "MoonShoes":
					child.queue_free()
			# Reset player properties
			player.position.y += 0.2
			player.collision_shape.position.y += 0.2
			player.shapecast.position.y += 0.2
			# Restore the original collision position for the crouching system
			player.collision_position.y += 0.2
			player.jump_velocity = initial_jump_velocity
			# Clear the references
			player = null


## Called when a Node3D enters the Area3D.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Check if the player is not skateboarding
		if !body.is_skateboarding:
			# Reparent the held item (if any)
			body.reparent_held_item()
			# Load the moon shoes scene
			var scene = load("res://scenes/moon_shoes.tscn")
			# Instantiate the scene for the left foot
			var left_instance = scene.instantiate()
			# Disable the pickup collision on both instances
			left_instance.get_node("Area3D/CollisionShape3D").disabled = true
			# Remove the right shoe from the left instance
			left_instance.get_node("Shoe2").queue_free()
			# Reset the transform to avoid position offset issues
			left_instance.transform = Transform3D.IDENTITY
			# Set the shoe's position to zero
			left_instance.get_node("Shoe").position = Vector3.ZERO
			# Set the player reference on the left instance (to handle the logic in the _input function)
			left_instance.player = body
			# Attach left shoe instance to left foot
			body.bone_attachement_left_foot.add_child(left_instance)
			# Instantiate the scene for the right foot
			var right_instance = scene.instantiate()
			# Disable the pickup collision on both instances
			right_instance.get_node("Area3D/CollisionShape3D").disabled = true
			# Remove the left shoe from right instance
			right_instance.get_node("Shoe").queue_free()
			# Reset the transform to avoid position offset issues
			right_instance.transform = Transform3D.IDENTITY
			# Set the shoe's position to zero
			right_instance.get_node("Shoe2").position = Vector3.ZERO
			# Attach right shoe instance to right foot
			body.bone_attachement_right_foot.add_child(right_instance)
			# Modify player properties when equipping
			body.collision_shape.position.y -= 0.2
			body.shapecast.position.y -= 0.2
			# Update the stored collision position so crouching system uses the adjusted position
			body.collision_position.y -= 0.2
			# Store the original jump velocity before modifying it (use left instance to store this)
			left_instance.initial_jump_velocity = body.jump_velocity
			body.jump_velocity = 9.0
			# Remove _this_ instance
			queue_free()
