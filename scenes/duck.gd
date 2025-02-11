extends CharacterBody3D

var player: CharacterBody3D
var follow_distance: float = 1.0
var follow_speed: float = 2.25
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
const quack_1 = preload("res://assets/duck/quack_1.wav")
const quack_2 = preload("res://assets/duck/quack_2.wav")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _on_area_3d_body_entered(body: Node3D) -> void:

	# Check if the body is a Player
	if body.is_in_group("Player"):
		player = body
		audio_player.stream = quack_2
		audio_player.play()


func _on_area_3d_body_exited(body: Node3D) -> void:

	# Check if the body is a Player
	if body.is_in_group("Player"):
		player = null
		velocity.x = 0
		velocity.z = 0
		audio_player.stream = quack_1
		audio_player.play()


func _process(delta: float) -> void:

	# Check if the player is not null
	if player:

		# Look at player
		look_at(player.global_position)

		# Calculate direction to player
		var direction = player.global_position - global_position
		var distance = direction.length()

		# Only move if we're further than follow_distance
		if distance > follow_distance:

			# Normalize direction and adjust speed
			direction = direction.normalized()
			velocity = direction * follow_speed

		else:
			# Stop moving when at correct distance
			velocity.x = 0
			velocity.z = 0

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Apply movement
	move_and_slide()
	
	play_animation()


func play_animation() -> void:
	if velocity.x != 0.0 or velocity.z != 0.0:
		if animation_player.current_animation != "Walk":
			animation_player.play("Walk")
	else:
		animation_player.play("Armature|White Duck_TempMotion|White Duck_TempMotion")
