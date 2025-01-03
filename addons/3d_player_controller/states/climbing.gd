extends Node

@onready var player: CharacterBody3D = get_parent().get_parent()


## Called when there is an input event.
func _input(event: InputEvent) -> void:

	# Check if the game is not paused
	if !Globals.game_paused:

		# [jump] button just _pressed_
		if Input.is_action_just_pressed("jump") and player.enable_jumping:

			# ToDo: Mantle up
			pass

		# [sprint] button just _pressed_
		if Input.is_action_just_pressed("sprint"):

			# ToDo: Drop down
			pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Check if the player is "climbing"
	if player.is_climbing:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# ToDo: Play the appropriate climbing animation
		pass


## Start "climbing".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	States.current_state = States.State.CLIMBING

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
	to_standing()


## Stop "climbing".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "climbing"
	player.is_climbing = false


## State.CLIMBING -> State.STANDING
func to_standing() -> void:

	# Stop "climbing"
	stop()

	# Start "standing"
	$"../Standing".start()
