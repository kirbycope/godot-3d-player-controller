extends Node3D

@onready var foam_sword_initial_transform: Transform3D
@onready var fishing_rod_initial_transform: Transform3D
@onready var player: CharacterBody3D = $Player
@onready var paraglider_initial_transform: Transform3D
@onready var portal_gun_initial_transform: Transform3D
@onready var moon_shoes_initial_transform: Transform3D
@onready var skateboard_initial_transform: Transform3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Rotate the Portal gun
	$"PortalGun/AnimationPlayer".play("rotate")
	# Get the transform of the not held items
	foam_sword_initial_transform = $FoamSword.global_transform
	fishing_rod_initial_transform = $FishingRod.global_transform
	paraglider_initial_transform = $Paraglider.global_transform
	portal_gun_initial_transform = $PortalGun.global_transform
	moon_shoes_initial_transform = $MoonShoes.global_transform
	skateboard_initial_transform = $Skateboard.global_transform


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Round up the orphaned nodes
	move_dropped_items_to_initial_position()


## Moves an orphaned, equippable "items" back to their spawn locations.
func move_dropped_items_to_initial_position() -> void:
	# Check if there is a foam sword as a child of the current scene
	if has_node("FoamSword"):
		# Check if the item (not held by the player) moved from its initial position
		if $FoamSword.global_position != foam_sword_initial_transform.origin:
			# Reset the item's position
			$FoamSword.global_transform = foam_sword_initial_transform
			# Enable the item's "pickup" collision
			$FoamSword/Area3D/CollisionShape3D.disabled = false
	# Check if there is a fishing rod as a child of the current scene
	if has_node("FishingRod"):
		# Check if the item (not held by the player) moved from its initial position
		if $FishingRod.global_position != fishing_rod_initial_transform.origin:
			# Reset the item's position
			$FishingRod.global_transform = fishing_rod_initial_transform
			# Enable the item's "pickup" collision
			$FishingRod/Area3D/CollisionShape3D.disabled = false
			# Stop any animations
			$FishingRod/AnimationPlayer.stop()
	# Check if there is a paraglider as a child of the current scene
	if has_node("Paraglider"):
		# Check if the item (not held by the player) moved from its initial position
		if $Paraglider.global_position != paraglider_initial_transform.origin:
			# Reset the item's position
			$Paraglider.global_transform = paraglider_initial_transform
			# Enable the item's "pickup" collision
			$Paraglider/Area3D/CollisionShape3D.disabled = false
	# Check if there is a portal gun as a child of the current scene
	if has_node("PortalGun"):
		# Check if the item (not held by the player) moved from its initial position
		if $PortalGun.global_position != portal_gun_initial_transform.origin:
			# Reset the item's position
			$PortalGun.global_transform = portal_gun_initial_transform
			# Enable the item's "pickup" collision
			$PortalGun/Area3D/CollisionShape3D.disabled = false
			# Start the rotate animation
			$PortalGun/AnimationPlayer.play("rotate")
	# Check if there are moon shoes as a child of the current scene
	if has_node("MoonShoes"):
		if $MoonShoes.global_position != moon_shoes_initial_transform.origin:
			# Check for each grandchild's name if it's "shoe" or "shoe2"
			for child in get_children():
				for grandchild in child.get_children():
					if grandchild.name == "Shoe":
						grandchild.queue_free()
					elif grandchild.name == "Shoe2":
						grandchild.queue_free()
			# Remove the moon shoes from the scene to prevent duplicate creation
			$MoonShoes.queue_free()
			# Create a new complete moon shoes instance to drop
			var scene = load("res://scenes/moon_shoes.tscn")
			var dropped_item = scene.instantiate()
			# Add the complete item to the current scene first
			player.get_tree().current_scene.add_child(dropped_item)
			# Now position the dropped item at its initial transform
			dropped_item.global_transform = moon_shoes_initial_transform
			# Enable the item's "pickup" collision
			dropped_item.get_node("Area3D/CollisionShape3D").disabled = false
			# [Hack] Reset player properties
			player.position.y += 0.2
			player.collision_shape.position.y += 0.2
			player.shapecast.position.y += 0.2
			# [Hack] Restore the original collision position for the crouching system
			player.collision_position.y += 0.2
			player.jump_velocity = 4.5

	# Check if there is a skateboard as a child of the current scene
	if has_node("Skateboard"):
		# Check if the item (not equipped by the player) moved from its initial position
		if $Skateboard.global_position != skateboard_initial_transform.origin:
			# Reset the item's position
			$Skateboard.global_transform = skateboard_initial_transform
			# Enable the item's "pickup" collision
			$Skateboard/Area3D/CollisionShape3D.disabled = false
			# Stop the skateboard sound effect
			$Skateboard/AudioStreamPlayer3D.stop()


## Called when a player enter the teleport area at the base of the tower.
func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if the collider is the player
	if body is CharacterBody3D and body.is_in_group("Player"):
		# Teleport the player on top of the tower
		body.position = $NavigationRegion3D/Tower.global_position + Vector3(0.0, $NavigationRegion3D/Tower.size.y/2, 0.0)
