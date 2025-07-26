extends RigidBody3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var last_audio_time: float = 0.0
var audio_cooldown: float = 0.2  # Minimum time between audio plays

func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if linear_velocity.length() > 0.2 and current_time - last_audio_time > audio_cooldown and not body is SoftBody3D:
		# Set volume based on velocity (higher velocity = louder sound)
		var velocity_magnitude = linear_velocity.length()
		# Map velocity to volume_db range for quieter overall volume
		var volume_db = lerp(-40.0, -10.0, min(velocity_magnitude / 10.0, 1.0))
		audio_stream_player_3d.volume_db = volume_db
		
		audio_stream_player_3d.play()
		last_audio_time = current_time
