extends Node

# Define states as an enum for clarity
enum State {
	CLIMBING,
	CRAWLING,
	CROUCHING,
	FALLING,
	FLYING,
	HANGING,
	JUMPING,
	RUNNING,
	SPRINTING,
	STANDING,
	WALKING
}

# Store the current state
@export var current_state: State = State.STANDING
