extends BaseState
## climbinig.gd

# States (states.gd)
#├── Base (base.gd)
#├── Climbing (climbing.gd)
#├── Crawling (crawling.gd)
#├── Crouching (crouching.gd)
#├── Driving (driving.gd)
#├── Falling (falling.gd)
#├── Flying (flying.gd)
#├── Hanging (hanging.gd)
#├── Holding (holding.gd)
#├── Jumping (jumping.gd)
#├── Running (running.gd)
#├── Skateboarding (skateboarding.gd)
#├── Sprinting (sprinting.gd)
#├── Standing (standing.gd)
#├── Swimming (swimming.gd)
#└── Walking (walking.gd)

const ANIMATION_CLIMBING_IN_PLACE = "Climbing_Up_Wall_In_Place" + "/mixamo_com"
const NODE_NAME := "Climbing"


## Called when there is an input event.
func _input(event: InputEvent) -> void:
	# Check if the game is not paused
	if !player.game_paused:
		# [jump] button just _pressed_
		if event.is_action_pressed("jump") and player.enable_jumping:
			# ToDo: Mantle up
			pass

		# [sprint] button just _pressed_
		if event.is_action_pressed("sprint"):
			# ToDo: Drop down
			pass


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return
	# Check if the player is "climbing"
	if player.is_climbing:
		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:
	# Check if the animation player is not locked
	if !player.is_animation_locked:
		# Check if the animation player is not already playing the appropriate animation
		if player.animation_player.current_animation != ANIMATION_CLIMBING_IN_PLACE:
			# Stop the current animation so no blending occurs
			player.animation_player.stop()

			# Play the "climbing" animation
			player.animation_player.play(ANIMATION_CLIMBING_IN_PLACE)


## Start "climbing".
func start() -> void:
	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = STATES.State.CLIMBING

	# Flag the player as "climbing" (also called "mantling")
	player.is_climbing = true

	# Find the target position
	var collision_point = player.raycast_jumptarget.get_collision_point()

	# Move the player
	var tween = player.get_tree().create_tween()
	tween.tween_property(player, "position", collision_point, 0.2)

	# Delay execution
	await get_tree().create_timer(0.2).timeout

	# Start "standing"
	transition(NODE_NAME, "Standing")


## Stop "climbing".
func stop() -> void:
	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false
