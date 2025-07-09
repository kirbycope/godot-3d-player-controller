extends CharacterBody3D

@onready var player: CharacterBody3D = get_parent().get_node("Player")

## Called when there is an input event.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		if player.raycast_lookat.is_colliding():
			if player.raycast_high.is_colliding() and player.raycast_high.get_collider().is_in_group("Pet"):
				player.animation_player.play("Petting_Animal_High" + "/mixamo_com")
			elif player.raycast_middle.is_colliding() and player.raycast_middle.get_collider().is_in_group("Pet"):
				player.animation_player.play("Petting_Animal_Mid" + "/mixamo_com")
			elif player.raycast_low.is_colliding() and player.raycast_low.get_collider().is_in_group("Pet"):
				player.animation_player.play("Petting_Animal_Low" + "/mixamo_com")
		if player.animation_player.current_animation in ["Petting_Animal_High" + "/mixamo_com", "Petting_Animal_Mid" + "/mixamo_com", "Petting_Animal_Low" + "/mixamo_com"]:
			player.is_animation_locked = true
			await get_tree().create_timer(2.0).timeout
			$AudioStreamPlayer3D.play()
			$AnimationPlayer.play("Arm_Cat|Caress_idle")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $AnimationPlayer.current_animation == "":
		$AnimationPlayer.play("Arm_Cat|Idle_1")
