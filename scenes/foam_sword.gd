extends Node3D

var player: CharacterBody3D


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_node("Player")
	player.is_holding_tool = true
	player.is_holding_onto = self

	# Defer the reparenting to avoid tree modification conflicts
	call_deferred("_reparent_to_held_mount")

## Reparents this node to the player's held item mount
func _reparent_to_held_mount() -> void:
	get_parent().remove_child(self)
	player.visuals.get_node("HeldItemMount").add_child(self)
