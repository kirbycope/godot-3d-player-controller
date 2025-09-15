extends BaseState

const NODE_NAME := "Ragdoll"

var time_ragdoll: float = 0.0 ## The time spent in the "ragdoll" state."


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event: InputEvent) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# (A)/[Space] _pressed_ after 3 seconds -> Stop ragdoll state
	if event.is_action_pressed("button_0") and time_ragdoll > 3.0:
		# Stop ragdoll and replicate to all clients
		trigger_ragdoll_stop.rpc()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Do nothing if not the authority
	if !is_multiplayer_authority(): return
	# Check if the game is not paused
	if !player.game_paused:
		time_ragdoll += delta
		# Move the player to their bones
		player.global_position = player.player_skeleton.get_node("PhysicalBoneSimulator3D/Physical Bone Hips").global_position


## Triggers ragdoll state and replicates to all clients
@rpc("any_peer", "call_local")
func trigger_ragdoll_start(current_state_name: String) -> void:
	# Transition to ragdoll state
	transition(current_state_name, NODE_NAME)


## Triggers ragdoll stop state and replicates to all clients
@rpc("any_peer", "call_local")
func trigger_ragdoll_stop() -> void:
	# Transition from ragdoll to standing state
	transition(NODE_NAME, "Standing")


## Start ragdoll state
func start() -> void:
	# Enable this state node
	process_mode = PROCESS_MODE_INHERIT
	# Set the player's new state
	player.current_state = STATES.State.RAGDOLL
	# Reset timer
	time_ragdoll = 0.0
	# Make sure the skeleton is at the current player position
	if not player.physical_bone_simulator:
		return
	# Ensure collision is disabled
	player.collision_shape.disabled = true
	player.shapecast.enabled = false
	# Now activate the ragdoll simulation
	player.physical_bone_simulator.active = true
	player.physical_bone_simulator.physical_bones_start_simulation()


## Stop ragdoll state
func stop() -> void:
	# Disable this state node
	process_mode = PROCESS_MODE_DISABLED
	# Ensure ragdoll is properly stopped
	if player.physical_bone_simulator.active:
		player.physical_bone_simulator.physical_bones_stop_simulation()
		player.physical_bone_simulator.active = false
	# Ensure collision is re-enabled
	player.collision_shape.disabled = false
	player.shapecast.enabled = true
	# [Re]Set time spent in ragdoll state
	time_ragdoll = 0.0
