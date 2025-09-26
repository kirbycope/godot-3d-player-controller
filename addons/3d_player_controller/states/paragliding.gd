extends BaseState

const ANIMATION_PARAGLIDING := "Hanging_Idle" + "/mixamo_com"
const NODE_NAME := "Paragliding"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓑ/[Shift] _pressed_ -> Stop paragliding and start "falling"
		if event.is_action_pressed("button_1"):
			# Start falling
			transition(NODE_NAME, "Falling")
		# (D-Pad Down)/[Q] _pressed_ -> Drop paraglider
		if event.is_action_pressed("button_13"):
			# Reparent the paraglider from the player to current scene
			player.reparent_equipped_head_items()
			# Check if the player is on the ground
			if player.is_on_floor():
				# Start standing
				transition(NODE_NAME, "Standing")
			# The player must not be on the ground
			else:
				# Start Falling
				transition(NODE_NAME, "Falling")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is about to land
	if player.raycast_below.is_colliding() and player.velocity.y <= 0.0:
		# Get the distance to the collision point
		var collision_distance = player.raycast_below.global_position.distance_to(player.raycast_below.get_collision_point())
		if collision_distance <= 0.2:
			# Start "standing"
			transition(NODE_NAME, "Standing")
	# Check if the player is on the ground (and has no vertical velocity)
	if player.is_on_floor() and player.velocity.y == 0.0:
		# Start "standing"
		transition(NODE_NAME, "Standing")
	# Check if the player is "paragliding"
	if player.is_paragliding:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if playing the "paragliding" animation
		if player.animation_player.current_animation != ANIMATION_PARAGLIDING:
			# Play the "paragliding" animation
			player.animation_player.play(ANIMATION_PARAGLIDING)


## Start "paragliding".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.PARAGLIDING
	# Flag the player as "paragliding"
	player.is_paragliding = true
	# Stop vertical velocity
	player.velocity.y = 0.0
	# Set the player's gravity
	player.gravity = 1.0


## Stop "paragliding".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "paragliding"
	player.is_paragliding = false
	# [Re]Set the player's gravity
	player.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
