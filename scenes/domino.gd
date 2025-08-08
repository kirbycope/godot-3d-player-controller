extends RigidBody3D

const CLACK_1 = preload("res://assets/sounds/domino/244724__reitanna__clack.wav")
const CLACK_2 = preload("res://assets/sounds/domino/407429__deezsoundztho__zippoclose.wav")

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var last_audio_time: float = 0.0
var scene_start_time: float = 0.0
var clack1_played: bool = false
var clack2_played: bool = false


func _ready() -> void:
	scene_start_time = Time.get_ticks_msec() / 1000.0


func _on_body_entered(body: Node) -> void:
	# Don't play sound in the first few seconds after scene loading
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - scene_start_time < 5.0:
		return
	
	# Ignore player and soft body collisions (for now)
	if body is not CharacterBody3D and not body is SoftBody3D:
		# Check if colliding with another domino
		if body.name == "DominoRigid":
			# Colliding with another domino - play CLACK_1 (if not already played)
			if not clack1_played:
				audio_stream_player_3d.stream = CLACK_1
				audio_stream_player_3d.play()
				clack1_played = true
		else:
			# Colliding with something else - play CLACK_2 (if not already played)
			if not clack2_played:
				audio_stream_player_3d.stream = CLACK_2
				audio_stream_player_3d.play()
				clack2_played = true


func _on_body_exited(_body: Node) -> void:
	if get_colliding_bodies().size() == 0:
		clack1_played = false
		clack2_played = false
