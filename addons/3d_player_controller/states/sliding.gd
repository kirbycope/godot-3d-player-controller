extends BaseState

const ANIMATION_SLIDING := "Running_Slide" + "/mixamo_com"
const NODE_NAME := "Sliding"


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Check if the player is "sliding"
		if player.is_sliding:
			# Play the animation
			play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_SLIDING:
			# Play the "sliding" animation
			player.animation_player.play(ANIMATION_SLIDING)
			# Start playing partway through the animation
			var animation_length = player.animation_player.get_animation(ANIMATION_SLIDING).length
			# Stop the animation early after a short duration
			var segment_duration = animation_length * 1.0  # Play for 100% of total length
			await get_tree().create_timer(segment_duration).timeout
			# Start "running"
			transition(NODE_NAME, "Running")


## Start "sliding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.ROLLING
	# Flag the player as "sliding"
	player.is_sliding = true
	# Set the player's speed
	player.speed_current = player.speed_running
	# Set CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2
	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position / 2


## Stop "sliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "sliding"
	player.is_sliding = false
	# Reset CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height
	# Reset CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position
