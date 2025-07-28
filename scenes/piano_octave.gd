extends Node3D

@onready var c_animation_player: AnimationPlayer = $C/AnimationPlayer
@onready var c_audio: AudioStreamPlayer3D = $C/StaticBody3D/AudioStreamPlayer3D
@onready var c_sharp_animation_player: AnimationPlayer = $"C#/AnimationPlayer"
@onready var c_sharp_audio: AudioStreamPlayer3D = $"C#/StaticBody3D/AudioStreamPlayer3D"
@onready var d_animation_player: AnimationPlayer = $"D/AnimationPlayer"
@onready var d_audio: AudioStreamPlayer3D = $D/StaticBody3D/AudioStreamPlayer3D
@onready var d_sharp_animation_player: AnimationPlayer = $"D#/AnimationPlayer"
@onready var d_sharp_audio: AudioStreamPlayer3D = $"D#/StaticBody3D/AudioStreamPlayer3D"
@onready var e_animation_player: AnimationPlayer = $"E/AnimationPlayer"
@onready var e_audio: AudioStreamPlayer3D = $E/StaticBody3D/AudioStreamPlayer3D
@onready var f_animation_player: AnimationPlayer = $"F/AnimationPlayer"
@onready var f_audio: AudioStreamPlayer3D = $F/StaticBody3D/AudioStreamPlayer3D
@onready var f_sharp_animation_player: AnimationPlayer = $"F#/AnimationPlayer"
@onready var f_sharp_audio: AudioStreamPlayer3D = $"F#/StaticBody3D/AudioStreamPlayer3D"
@onready var g_animation_player: AnimationPlayer = $"G/AnimationPlayer"
@onready var g_audio: AudioStreamPlayer3D = $G/StaticBody3D/AudioStreamPlayer3D
@onready var g_sharp_animation_player: AnimationPlayer = $"G#/AnimationPlayer"
@onready var g_sharp_audio: AudioStreamPlayer3D = $"G#/StaticBody3D/AudioStreamPlayer3D"
@onready var a_animation_player: AnimationPlayer = $"A/AnimationPlayer"
@onready var a_audio: AudioStreamPlayer3D = $A/StaticBody3D/AudioStreamPlayer3D
@onready var a_sharp_animation_player: AnimationPlayer = $"A#/AnimationPlayer"
@onready var a_sharp_audio: AudioStreamPlayer3D = $"A#/StaticBody3D/AudioStreamPlayer3D"
@onready var b_animation_player: AnimationPlayer = $"B/AnimationPlayer"
@onready var b_audio: AudioStreamPlayer3D = $B/StaticBody3D/AudioStreamPlayer3D


func _on_c_body_entered(_body: Node3D) -> void:
	c_audio.play()
	c_animation_player.play("press")

func _on_c_sharp_body_entered(_body: Node3D) -> void:
	c_sharp_audio.play()
	c_sharp_animation_player.play("press")

func _on_d_body_entered(_body: Node3D) -> void:
	d_audio.play()
	d_animation_player.play("press")

func _on_d_sharp_body_entered(_body: Node3D) -> void:
	d_sharp_audio.play()
	d_sharp_animation_player.play("press")

func _on_e_body_entered(_body: Node3D) -> void:
	e_audio.play()
	e_animation_player.play("press")

func _on_f_body_entered(_body: Node3D) -> void:
	f_audio.play()
	f_animation_player.play("press")

func _on_f_sharp_body_entered(_body: Node3D) -> void:
	f_sharp_audio.play()
	f_sharp_animation_player.play("press")

func _on_g_body_entered(_body: Node3D) -> void:
	g_audio.play()
	g_animation_player.play("press")

func _on_g_sharp_body_entered(_body: Node3D) -> void:
	g_sharp_audio.play()
	g_sharp_animation_player.play("press")

func _on_a_body_entered(_body: Node3D) -> void:
	a_audio.play()
	a_animation_player.play("press")

func _on_a_sharp_body_entered(_body: Node3D) -> void:
	a_sharp_audio.play()
	a_sharp_animation_player.play("press")

func _on_b_body_entered(_body: Node3D) -> void:
	b_audio.play()
	b_animation_player.play("press")


func _on_c_body_exited(_body: Node3D) -> void:
	c_animation_player.play_backwards("press")

func _on_c_sharp_body_exited(_body: Node3D) -> void:
	c_sharp_animation_player.play_backwards("press")

func _on_d_body_exited(_body: Node3D) -> void:
	d_animation_player.play_backwards("press")

func _on_d_sharp_body_exited(_body: Node3D) -> void:
	d_sharp_animation_player.play_backwards("press")

func _on_e_body_exited(_body: Node3D) -> void:
	e_animation_player.play_backwards("press")

func _on_f_body_exited(_body: Node3D) -> void:
	f_animation_player.play_backwards("press")

func _on_f_sharp_body_exited(_body: Node3D) -> void:
	f_sharp_animation_player.play_backwards("press")

func _on_g_body_exited(_body: Node3D) -> void:
	g_animation_player.play_backwards("press")

func _on_g_sharp_body_exited(_body: Node3D) -> void:
	g_sharp_animation_player.play_backwards("press")

func _on_a_body_exited(_body: Node3D) -> void:
	a_animation_player.play_backwards("press")

func _on_a_sharp_body_exited(_body: Node3D) -> void:
	a_sharp_animation_player.play_backwards("press")

func _on_b_body_exited(_body: Node3D) -> void:
	b_animation_player.play_backwards("press")
