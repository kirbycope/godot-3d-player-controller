extends RigidBody3D

const WOOD_1 = preload("res://assets/sounds/wood/94859__cjosephwalker__foley-wood-sword-fall.wav")
const WOOD_2 = preload("res://assets/sounds/wood/653128__marb7e__wood_plank_impact_ground.wav")

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var last_audio_time: float = 0.0
var audio_cooldown: float = 0.2


func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	# Ignore player and soft body collisions (for now)
	if body is not CharacterBody3D and not body is SoftBody3D:
		var current_time = Time.get_ticks_msec() / 1000.0
		# Check if the time is past the cool down
		if current_time - last_audio_time > audio_cooldown:
			# Chose 1 of 2 sound files
			var sound_choice = randi() % 2
			match sound_choice:
				0:
					audio_stream_player_3d.stream = WOOD_1
				1:
					audio_stream_player_3d.stream = WOOD_2
			# Play the selected sound
			audio_stream_player_3d.play()
			# Note when the sound was played
			last_audio_time = current_time
