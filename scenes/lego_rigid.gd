extends RigidBody3D

const SFX_1 = preload("res://assets/sounds/lego/104824__cgeffex__lego_click1.wav")
const SFX_2 = preload("res://assets/sounds/lego/104825__cgeffex__lego_click2.wav")
const SFX_3 = preload("res://assets/sounds/lego/104826__cgeffex__lego_click3.wav")

@export var velocity_threshold: float = 5.0 ## Minimum velocity magnitude to play sound

var audio_cooldown: float = 0.2
var last_audio_time: float = 0.0
var scene_start_time: float = 0.0

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	scene_start_time = Time.get_ticks_msec() / 1000.0


## Recursively apply color to all mesh nodes
func apply_color_to_mesh(node: Node, color: Color) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			if color == Color(0, 0, 0, 0):
				child.material_override = null
			else:
				if child.material_override == null:
					child.material_override = StandardMaterial3D.new()
				child.material_override.albedo_color = color
		apply_color_to_mesh(child, color)


func _on_body_entered(body: Node) -> void:
	# WIP - BEGIN
	#if body.is_in_group("Lego"):
	#	var color = Color(255, 0, 0, 255)
	#	apply_color_to_mesh(body, color)
	# WIP - END
	# Don't play sound in the first few seconds after scene loading
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - scene_start_time < 5.0:
		return

	# Ignore small collisions
	var body_velocity = 0.0
	var volume_db = 0.0
	# Check the get_linear_velocity() of the collider
	if body.has_method("get_linear_velocity"):
		body_velocity = body.get_linear_velocity()
		if body_velocity.length() > velocity_threshold:
			volume_db = lerp(-40.0, -10.0, min(abs(body_velocity.length()) / 10.0, 1.0))
		else:
			return
	# Check the linear velocity of the collider
	elif body.has_method("has_variable") and body.has_variable("linear_velocity"):
		body_velocity = body.linear_velocity
		if body_velocity.length() > velocity_threshold:
			volume_db = lerp(-40.0, -10.0, min(abs(body_velocity.length()) / 10.0, 1.0))
		else:
			return
	# Check the linear velocity of _this_ node
	else:
		if linear_velocity.length() >= 0.2:
			volume_db = lerp(-40.0, -10.0, min(abs(linear_velocity.length()) / 10.0, 1.0))
			volume_db = 0.0
		else:
			return

	# Ignore player and soft body collisions (for now)
	if body is not CharacterBody3D and not body is SoftBody3D:
		# Check if the time is past the cool down
		if current_time - last_audio_time > audio_cooldown:
			# Chose 1 of the sound files
			var sound_choice = randi() % 3
			match sound_choice:
				0:
					audio_stream_player_3d.stream = SFX_1
				1:
					audio_stream_player_3d.stream = SFX_2
				2:
					audio_stream_player_3d.stream = SFX_3
			# Map velocity to volume_db range
			audio_stream_player_3d.volume_db = volume_db
			# Play the sound effct
			audio_stream_player_3d.play()
			# Note when the sound was played
			last_audio_time = current_time


func _on_body_exited(body: Node) -> void:
	# WIP - BEGIN
	#if body.is_in_group("Lego"):
	#	var color = Color(0, 0, 0, 0)
	#	apply_color_to_mesh(body, color)
	# WIP - END
	pass
