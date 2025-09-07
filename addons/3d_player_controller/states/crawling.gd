extends BaseState

const ANIMATION_CRAWLING := "Crawling_In_Place" + "/mixamo_com"
const ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE := "Rifle_Walk_Crouching" + "/mixamo_com"
const NODE_NAME := "Crawling"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		# Ⓐ/[Space] button just _pressed_
		if event.is_action_pressed("button_0") and player.enable_jumping and !player.is_animation_locked:
			# Start "jumping"
			transition(NODE_NAME, "Jumping")
		# Ⓑ/[Shift] _pressed -> Start "rolling"
		if event.is_action_pressed("button_1") and player.enable_rolling and !player.is_animation_locked:
			# Start "rolling"
			transition(NODE_NAME, "Rolling")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the player is not moving
	if player.velocity == Vector3.ZERO:
		# Start "crouching"		
		transition(NODE_NAME, "Crouching")
	# Ⓨ/[Ctrl] just _released_
	if Input.is_action_just_released("button_3"):
		# Start "standing"
		transition(NODE_NAME, "Standing")
	# Check if the player is "crawling"
	if player.is_crawling:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if in first person and moving backwards
		var play_backwards = player.perspective == 1 and Input.is_action_pressed("move_down")
		# Check if the player is "holding a rifle"
		if player.is_holding_rifle:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE:
				# Play the "crouching and moving, holding a rifle" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE)
				else:
					player.animation_player.play(ANIMATION_CROUCHING_MOVE_HOLDING_RIFLE, -1, 0.75)
		# The player must be unarmed
		else:
			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != ANIMATION_CRAWLING:
				# Play the "crawling" animation
				if play_backwards:
					player.animation_player.play_backwards(ANIMATION_CRAWLING)
				else:
					player.animation_player.play(ANIMATION_CRAWLING)


## Start "crawling".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.CRAWLING
	# Flag the player as "crawling"
	player.is_crawling = true
	# Set the player's movement speed
	player.speed_current = player.speed_crawling
	# Set CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height / 2
	# Set CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position / 2


## Stop "crawling".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED
	# Flag the player as not "crawling"
	player.is_crawling = false
	# Reset CollisionShape3D height
	player.get_node("CollisionShape3D").shape.height = player.collision_height
	# Reset CollisionShape3D position
	player.get_node("CollisionShape3D").position = player.collision_position
