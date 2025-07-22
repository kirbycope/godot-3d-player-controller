extends Node3D

@onready var fishing_rod_initial_transform: Transform3D
@onready var player: CharacterBody3D = $Player
@onready var portal_gun_initial_transform: Transform3D
@onready var skateboard_initial_transform: Transform3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Rotate the Portal gun
	$"PortalGun/AnimationPlayer".play("rotate")

	# Get the transform of the not held items
	fishing_rod_initial_transform = $FishingRod.global_transform
	portal_gun_initial_transform = $PortalGun.global_transform
	skateboard_initial_transform = $Skateboard.global_transform


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Check if there is a fishing rod as a child of the current scene
	if has_node("FishingRod"):
		# Check if the fishing rod (not held by the player) moved from its initial position
		if $FishingRod.global_position != fishing_rod_initial_transform.origin:
			# Reset the fishing rod's position
			$FishingRod.global_transform = fishing_rod_initial_transform
			# Enable the item's "pickup" collision
			$FishingRod/Area3D/CollisionShape3D.disabled = false
			# Stop any animations
			$FishingRod/AnimationPlayer.stop()
	# Check if there is a portal gun as a child of the current scene
	if has_node("PortalGun"):
		# Check if the portal gun (not held by the player) moved from its initial position
		if $PortalGun.global_position != portal_gun_initial_transform.origin:
			# Reset the portal gun's position
			$PortalGun.global_transform = portal_gun_initial_transform
			# Enable the item's "pickup" collision
			$PortalGun/Area3D/CollisionShape3D.disabled = false
			# Start the rotate animation
			$PortalGun/AnimationPlayer.play("rotate")
	# Check if there is a skateboard as a child of the current scene
	if has_node("Skateboard"):
		# Check if the skateboard (not held by the player) moved from its initial position
		if $Skateboard.global_position != skateboard_initial_transform.origin:
			# Reset the skateboard's position
			$Skateboard.global_transform = skateboard_initial_transform
			# Enable the item's "pickup" collision
			$Skateboard/Area3D/CollisionShape3D.disabled = false
			# Stop the skateboard sound effect
			$Skateboard/AudioStreamPlayer3D.stop()


## Reparent the held item to the root of the scene tree.
func reparent_held_item() -> void:
	# Check if the player is holding an item
	if player.is_holding_onto != null:
		# Remove the item from the player
		player.visuals.get_node("HeldItemMount").remove_child(player.is_holding_onto)
		# Reparent the item to the main scene
		get_tree().current_scene.add_child(player.is_holding_onto)
		# Stop holding the item
		player.is_holding_onto = null
		player.is_holding_fishing_rod = false
		player.is_holding_rifle = false
