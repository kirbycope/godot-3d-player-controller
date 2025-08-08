extends RigidBody3D

const LOG_1 = preload("res://assets/sounds/log/258061__jagadamba__large-piece-of-wood-being-dropped-01-1.mp3")
const LOG_2 = preload("res://assets/sounds/log/258065__jagadamba__large-piece-of-wood-being-dropped-03-1.mp3")
const LOG_3 = preload("res://assets/sounds/log/258066__jagadamba__large-piece-of-wood-being-dropped-02-1.mp3")

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var audio_cooldown: float = 0.2
var last_audio_time: float = 0.0
var scene_start_time: float = 0.0


func _ready() -> void:
	scene_start_time = Time.get_ticks_msec() / 1000.0


func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	# Don't play sound in the first few seconds after scene loading
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - scene_start_time < 5.0:
		return
	# Ignore player and soft body collisions (for now)
	if body is not CharacterBody3D and not body is SoftBody3D:
		# Check if the time is past the cool down
		if current_time - last_audio_time > audio_cooldown:
			# Chose 1 of 2 sound files
			var sound_choice = randi() % 3
			match sound_choice:
				0:
					audio_stream_player_3d.stream = LOG_1
				1:
					audio_stream_player_3d.stream = LOG_2
				2:
					audio_stream_player_3d.stream = LOG_3
			# Play the selected sound
			audio_stream_player_3d.play()
			# Note when the sound was played
			last_audio_time = current_time
