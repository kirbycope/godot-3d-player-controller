extends RigidBody3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var last_audio_time: float = 0.0
var audio_cooldown: float = 0.2


func _on_body_entered(body: Node) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if linear_velocity.length() > 0.2 and current_time - last_audio_time > audio_cooldown and not body is SoftBody3D:
		# Set volume based on velocity
		var velocity_magnitude = linear_velocity.length()
		# Map velocity to volume_db range
		var volume_db = lerp(-40.0, -10.0, min(abs(velocity_magnitude) / 10.0, 1.0))
		audio_stream_player_3d.volume_db = volume_db
		# Play the sound effect
		audio_stream_player_3d.play()
		last_audio_time = current_time
