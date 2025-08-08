extends RigidBody3D

const SFX_1 = preload("res://assets/sounds/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_k1.wav")
const SFX_2 = preload("res://assets/sounds/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_k2.wav")
const SFX_3 = preload("res://assets/sounds/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_k3.wav")
const SFX_4 = preload("res://assets/sounds/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_p1.wav")
const SFX_5 = preload("res://assets/sounds/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_p2.wav")
const SFX_6 = preload("res://assets/sounds/punching_bag/594416__cashcarlo__punching-bag-being-punched-outside_p3.wav")

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $"../AudioStreamPlayer3D"


func animate_hit_low_left() -> void:
	play_kick_sound()


func animate_hit_low_right() -> void:
	play_kick_sound()


func animate_hit_high_left() -> void:
	play_punch_sound()


func animate_hit_high_right() -> void:
	play_punch_sound()


func play_kick_sound() -> void:
	var sound_choice = randi() % 3
	match sound_choice:
		0:
			audio_stream_player_3d.stream = SFX_1
		1:
			audio_stream_player_3d.stream = SFX_2
		2:
			audio_stream_player_3d.stream = SFX_3
	# Play the sound effct
	audio_stream_player_3d.play()


func play_punch_sound() -> void:
	var sound_choice = randi() % 3
	match sound_choice:
		0:
			audio_stream_player_3d.stream = SFX_4
		1:
			audio_stream_player_3d.stream = SFX_5
		2:
			audio_stream_player_3d.stream = SFX_6
	# Play the sound effct
	audio_stream_player_3d.play()
