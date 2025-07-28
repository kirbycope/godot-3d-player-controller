extends Node3D

@onready var c = $"C"
@onready var c_animation_player: AnimationPlayer = c.get_node("AnimationPlayer")
@onready var c_area: Area3D = c.get_node("Area3D")
@onready var c_audio: AudioStreamPlayer3D = c.get_node("AudioStreamPlayer3D")
@onready var c_body: StaticBody3D = c.get_node("StaticBody3D")

@onready var c_sharp = $"C#"
@onready var c_sharp_animation_player: AnimationPlayer = c_sharp.get_node("AnimationPlayer")
@onready var c_sharp_area: Area3D = c_sharp.get_node("Area3D")
@onready var c_sharp_audio: AudioStreamPlayer3D = c_sharp.get_node("AudioStreamPlayer3D")
@onready var c_sharp_body: StaticBody3D = c_sharp.get_node("StaticBody3D")

@onready var d = $"D"
@onready var d_animation_player: AnimationPlayer = d.get_node("AnimationPlayer")
@onready var d_area: Area3D = d.get_node("Area3D")
@onready var d_audio: AudioStreamPlayer3D = d.get_node("AudioStreamPlayer3D")
@onready var d_body: StaticBody3D = d.get_node("StaticBody3D")

@onready var d_sharp = $"D#"
@onready var d_sharp_animation_player: AnimationPlayer = d_sharp.get_node("AnimationPlayer")
@onready var d_sharp_area: Area3D = d_sharp.get_node("Area3D")
@onready var d_sharp_audio: AudioStreamPlayer3D = d_sharp.get_node("AudioStreamPlayer3D")
@onready var d_sharp_body: StaticBody3D = d_sharp.get_node("StaticBody3D")

@onready var e = $"E"
@onready var e_animation_player: AnimationPlayer = e.get_node("AnimationPlayer")
@onready var e_area: Area3D = e.get_node("Area3D")
@onready var e_audio: AudioStreamPlayer3D = e.get_node("AudioStreamPlayer3D")
@onready var e_body: StaticBody3D = e.get_node("StaticBody3D")

@onready var f = $"F"
@onready var f_animation_player: AnimationPlayer = f.get_node("AnimationPlayer")
@onready var f_area: Area3D = f.get_node("Area3D")
@onready var f_audio: AudioStreamPlayer3D = f.get_node("AudioStreamPlayer3D")
@onready var f_body: StaticBody3D = f.get_node("StaticBody3D")

@onready var f_sharp = $"F#"
@onready var f_sharp_animation_player: AnimationPlayer = f_sharp.get_node("AnimationPlayer")
@onready var f_sharp_area: Area3D = f_sharp.get_node("Area3D")
@onready var f_sharp_audio: AudioStreamPlayer3D = f_sharp.get_node("AudioStreamPlayer3D")
@onready var f_sharp_body: StaticBody3D = f_sharp.get_node("StaticBody3D")

@onready var g = $"G"
@onready var g_animation_player: AnimationPlayer = g.get_node("AnimationPlayer")
@onready var g_area: Area3D = g.get_node("Area3D")
@onready var g_audio: AudioStreamPlayer3D = g.get_node("AudioStreamPlayer3D")
@onready var g_body: StaticBody3D = g.get_node("StaticBody3D")

@onready var g_sharp = $"G#"
@onready var g_sharp_animation_player: AnimationPlayer = g_sharp.get_node("AnimationPlayer")
@onready var g_sharp_area: Area3D = g_sharp.get_node("Area3D")
@onready var g_sharp_audio: AudioStreamPlayer3D = g_sharp.get_node("AudioStreamPlayer3D")
@onready var g_sharp_body: StaticBody3D = g_sharp.get_node("StaticBody3D")

@onready var a = $"A"
@onready var a_animation_player: AnimationPlayer = a.get_node("AnimationPlayer")
@onready var a_area: Area3D = a.get_node("Area3D")
@onready var a_audio: AudioStreamPlayer3D = a.get_node("AudioStreamPlayer3D")
@onready var a_body: StaticBody3D = a.get_node("StaticBody3D")

@onready var a_sharp = $"A#"
@onready var a_sharp_animation_player: AnimationPlayer = a_sharp.get_node("AnimationPlayer")
@onready var a_sharp_area: Area3D = a_sharp.get_node("Area3D")
@onready var a_sharp_audio: AudioStreamPlayer3D = a_sharp.get_node("AudioStreamPlayer3D")
@onready var a_sharp_body: StaticBody3D = a_sharp.get_node("StaticBody3D")

@onready var b = $"B"
@onready var b_animation_player: AnimationPlayer = b.get_node("AnimationPlayer")
@onready var b_area: Area3D = b.get_node("Area3D")
@onready var b_audio: AudioStreamPlayer3D = b.get_node("AudioStreamPlayer3D")
@onready var b_body: StaticBody3D = b.get_node("StaticBody3D")


func _on_c_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if c_body.rotation_degrees.x == 0.0:
			c_audio.play()
			c_animation_player.play("press")

func _on_c_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if c_body.rotation_degrees.x != 0.0 and !c_animation_player.is_playing():
			c_animation_player.play_backwards("press")

func _on_c_sharp_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if c_sharp_body.rotation_degrees.x == 0.0:
			c_sharp_audio.play()
			c_sharp_animation_player.play("press")

func _on_c_sharp_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if c_sharp_body.rotation_degrees.x != 0.0 and !c_sharp_animation_player.is_playing():
			c_sharp_animation_player.play_backwards("press")

func _on_d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if d_body.rotation_degrees.x == 0.0:
			d_audio.play()
			d_animation_player.play("press")

func _on_d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if d_body.rotation_degrees.x != 0.0 and !d_animation_player.is_playing():
			d_animation_player.play_backwards("press")

func _on_d_sharp_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if d_sharp_body.rotation_degrees.x == 0.0:
			d_sharp_audio.play()
			d_sharp_animation_player.play("press")

func _on_d_sharp_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if d_sharp.rotation_degrees.x != 0.0 and !d_sharp_animation_player.is_playing():
			d_sharp_animation_player.play_backwards("press")

func _on_e_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if e_body.rotation_degrees.x == 0.0:
			e_audio.play()
			e_animation_player.play("press")

func _on_e_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if e_body.rotation_degrees.x != 0.0 and !e_animation_player.is_playing():
			e_animation_player.play_backwards("press")

func _on_f_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if f_body.rotation_degrees.x == 0.0:
			f_audio.play()
			f_animation_player.play("press")

func _on_f_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if f_body.rotation_degrees.x != 0.0 and !f_animation_player.is_playing():
			f_animation_player.play_backwards("press")

func _on_f_sharp_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if f_sharp_body.rotation_degrees.x == 0.0:
			f_sharp_audio.play()
			f_sharp_animation_player.play("press")

func _on_f_sharp_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if f_sharp_body.rotation_degrees.x != 0.0 and !f_sharp_animation_player.is_playing():
			f_sharp_animation_player.play_backwards("press")

func _on_g_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if g_body.rotation_degrees.x == 0.0:
			g_audio.play()
			g_animation_player.play("press")

func _on_g_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if g_body.rotation_degrees.x != 0.0 and !g_animation_player.is_playing():
			g_animation_player.play_backwards("press")

func _on_g_sharp_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if g_sharp_body.rotation_degrees.x == 0.0:
			g_sharp_audio.play()
			g_sharp_animation_player.play("press")

func _on_g_sharp_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if g_sharp_body.rotation_degrees.x != 0.0 and !g_sharp_animation_player.is_playing():
			g_sharp_animation_player.play_backwards("press")

func _on_a_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if a_body.rotation_degrees.x == 0.0:
			a_audio.play()
			a_animation_player.play("press")

func _on_a_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if a_body.rotation_degrees.x != 0.0 and !a_animation_player.is_playing():
			a_animation_player.play_backwards("press")

func _on_a_sharp_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if a_sharp_body.rotation_degrees.x == 0.0:
			a_sharp_audio.play()
			a_sharp_animation_player.play("press")

func _on_a_sharp_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if a_sharp_body.rotation_degrees.x != 0.0 and !a_sharp_animation_player.is_playing():
			a_sharp_animation_player.play_backwards("press")

func _on_b_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if b_body.rotation_degrees.x == 0.0:
			b_audio.play()
			b_animation_player.play("press")

func _on_b_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		if b_body.rotation_degrees.x != 0.0:
			b_animation_player.play_backwards("press")
