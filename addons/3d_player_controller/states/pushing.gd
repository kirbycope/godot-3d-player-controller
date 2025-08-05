extends BaseState

const ANIMATION_PUSHING := "Push_In_Place" + "/mixamo_com"
const NODE_NAME := "Pushing"

# ToDo: Square up the player when moving directly into the object
# ToDo: Move to "standing" when moving away from the object

## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	# Check if the player is moving and the is nothing blocking the player
	if player.velocity != Vector3.ZERO and not (player.raycast_middle.is_colliding() or player.raycast_high.is_colliding()):
		# Start "standing"
		transition(NODE_NAME, "Standing")

	# Check if the player is not moving
	if not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")):
		# Start "standing"
		transition(NODE_NAME, "Standing")

	# Check if the player is "pushing"
	if player.is_pushing:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_PUSHING:
			# Play the "pushing" animation
			player.animation_player.play(ANIMATION_PUSHING)


## Start "pushing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Flag the player as "pushing"
	player.is_pushing = true

	# Adjust visuals
	player.visuals.position.y -= 0.1
	player.visuals.position.z += 0.1


## Stop "pushing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "pushing"
	player.is_pushing = false

	# [Re]Set visuals
	player.visuals.position.y += 0.1
	player.visuals.position.z -= 0.1
