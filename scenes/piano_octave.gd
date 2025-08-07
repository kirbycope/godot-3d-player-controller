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


func is_valid_body(body):
	return body is CharacterBody3D or body is RigidBody3D or body is SoftBody3D


func is_key_pressed(key_rotation: Vector3) -> bool:
	# Use a small epsilon to handle floating point precision issues
	return key_rotation.length_squared() > 0.001

func _on_timer_timeout() -> void:
	if is_key_pressed(c_body.rotation):
		_on_c_body_exited(null)
	if is_key_pressed(c_sharp_body.rotation):
		_on_c_sharp_body_exited(null)
	if is_key_pressed(d_body.rotation):
		_on_d_body_exited(null)
	if is_key_pressed(d_sharp_body.rotation):
		_on_d_sharp_body_exited(null)
	if is_key_pressed(e_body.rotation):
		_on_e_body_exited(null)
	if is_key_pressed(f_body.rotation):
		_on_f_body_exited(null)
	if is_key_pressed(f_sharp_body.rotation):
		_on_f_sharp_body_exited(null)
	if is_key_pressed(g_body.rotation):
		_on_g_body_exited(null)
	if is_key_pressed(g_sharp_body.rotation):
		_on_g_sharp_body_exited(null)
	if is_key_pressed(a_body.rotation):
		_on_a_body_exited(null)
	if is_key_pressed(a_sharp_body.rotation):
		_on_a_sharp_body_exited(null)
	if is_key_pressed(b_body.rotation):
		_on_b_body_exited(null)


func _on_c_body_entered(body: Node3D) -> void:
	if !is_key_pressed(c_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			c_audio.play()
			c_animation_player.play("press")

func _on_c_body_exited(_body: Node3D) -> void:
	if c_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !c_animation_player.is_playing():
			c_animation_player.play_backwards("press")

func _on_c_sharp_body_entered(body: Node3D) -> void:
	if !is_key_pressed(c_sharp_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			c_sharp_audio.play()
			c_sharp_animation_player.play("press")

func _on_c_sharp_body_exited(_body: Node3D) -> void:
	if c_sharp_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !c_sharp_animation_player.is_playing():
			c_sharp_animation_player.play_backwards("press")

func _on_d_body_entered(body: Node3D) -> void:
	if !is_key_pressed(d_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			d_audio.play()
			d_animation_player.play("press")

func _on_d_body_exited(_body: Node3D) -> void:
	if d_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !d_animation_player.is_playing():
			d_animation_player.play_backwards("press")

func _on_d_sharp_body_entered(body: Node3D) -> void:
	if !is_key_pressed(d_sharp_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			d_sharp_audio.play()
			d_sharp_animation_player.play("press")

func _on_d_sharp_body_exited(_body: Node3D) -> void:
	if d_sharp_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !d_sharp_animation_player.is_playing():
			d_sharp_animation_player.play_backwards("press")

func _on_e_body_entered(body: Node3D) -> void:
	if !is_key_pressed(e_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			e_audio.play()
			e_animation_player.play("press")

func _on_e_body_exited(_body: Node3D) -> void:
	if e_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !e_animation_player.is_playing():
			e_animation_player.play_backwards("press")

func _on_f_body_entered(body: Node3D) -> void:
	if !is_key_pressed(f_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			f_audio.play()
			f_animation_player.play("press")

func _on_f_body_exited(_body: Node3D) -> void:
	if f_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !f_animation_player.is_playing():
			f_animation_player.play_backwards("press")

func _on_f_sharp_body_entered(body: Node3D) -> void:
	if !is_key_pressed(f_sharp_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			f_sharp_audio.play()
			f_sharp_animation_player.play("press")

func _on_f_sharp_body_exited(_body: Node3D) -> void:
	if f_sharp_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !f_sharp_animation_player.is_playing():
			f_sharp_animation_player.play_backwards("press")

func _on_g_body_entered(body: Node3D) -> void:
	if !is_key_pressed(g_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			g_audio.play()
			g_animation_player.play("press")

func _on_g_body_exited(_body: Node3D) -> void:
	if g_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !g_animation_player.is_playing():
			g_animation_player.play_backwards("press")

func _on_g_sharp_body_entered(body: Node3D) -> void:
	if !is_key_pressed(g_sharp_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			g_sharp_audio.play()
			g_sharp_animation_player.play("press")

func _on_g_sharp_body_exited(_body: Node3D) -> void:
	if g_sharp_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !g_sharp_animation_player.is_playing():
			g_sharp_animation_player.play_backwards("press")

func _on_a_body_entered(body: Node3D) -> void:
	if !is_key_pressed(a_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			a_audio.play()
			a_animation_player.play("press")

func _on_a_body_exited(_body: Node3D) -> void:
	if a_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !a_animation_player.is_playing():
			a_animation_player.play_backwards("press")

func _on_a_sharp_body_entered(body: Node3D) -> void:
	if !is_key_pressed(a_sharp_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			a_sharp_audio.play()
			a_sharp_animation_player.play("press")

func _on_a_sharp_body_exited(_body: Node3D) -> void:
	if a_sharp_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !a_sharp_animation_player.is_playing():
			a_sharp_animation_player.play_backwards("press")

func _on_b_body_entered(body: Node3D) -> void:
	if !is_key_pressed(b_body.rotation):
		if body is CharacterBody3D or body is RigidBody3D:
			b_audio.play()
			b_animation_player.play("press")

func _on_b_body_exited(_body: Node3D) -> void:
	if b_area.get_overlapping_bodies().filter(is_valid_body).size() == 0:
		if !b_animation_player.is_playing():
			b_animation_player.play_backwards("press")
