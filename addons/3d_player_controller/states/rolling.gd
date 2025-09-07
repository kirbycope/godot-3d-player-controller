extends BaseState

const ANIMATION_ROLLING := "Roll_In_Place" + "/mixamo_com"
const NODE_NAME := "Rolling"


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Check if the player is "rolling"
		if player.is_rolling:
			# Play the animation
			play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_ROLLING:
			# Play the "rolling" animation
			player.animation_player.play(ANIMATION_ROLLING)
			# Start playing partway through the animation
			var animation_length = player.animation_player.get_animation(ANIMATION_ROLLING).length
			# Stop the animation early after a short duration
			var segment_duration = animation_length * 0.8  # Play for 80% of total length
			await get_tree().create_timer(segment_duration).timeout
			# Check if the player is still holding the [crouch] button
			if Input.is_action_pressed("button_1"):
				# Transition to "Crawling"
				transition(NODE_NAME, "Crawling")
			else:
				# Transition to "Standing"
				transition(NODE_NAME, "Standing")


## Start "rolling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.ROLLING
	# Flag the player as "rolling"
	player.is_rolling = true
	# Set the player's speed
	player.speed_current = player.speed_rolling
	# Set CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2
	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position / 2


## Stop "rolling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "rolling"
	player.is_rolling = false
	# Reset CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height
	# Reset CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position
