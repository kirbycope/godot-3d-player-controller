extends RigidBody3D

const WOOD_1 = preload("res://assets/sounds/wood/94859__cjosephwalker__foley-wood-sword-fall.wav")
const WOOD_2 = preload("res://assets/sounds/wood/653128__marb7e__wood_plank_impact_ground.wav")

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var audio_cooldown: float = 0.2
var last_audio_time: float = 0.0
var scene_start_time: float = 0.0


func _ready() -> void:
	scene_start_time = Time.get_ticks_msec() / 1000.0


func _on_body_entered(body: Node) -> void:
	# Don't play sound in the first few seconds after scene loading
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - scene_start_time < 5.0:
		return

	# Ignore player and soft body collisions (for now)
	if body is not CharacterBody3D and not body is SoftBody3D:
		# Check if the time is past the cool down
		if current_time - last_audio_time > audio_cooldown:
			# Chose 1 of 2 sound files
			var sound_choice = randi() % 2
			match sound_choice:
				0:
					audio_stream_player_3d.stream = WOOD_1
				1:
					audio_stream_player_3d.stream = WOOD_2
			# Play the sound effct
			audio_stream_player_3d.play()
			# Note when the sound was played
			last_audio_time = current_time