extends StaticBody3D

@onready var bag = $Bag

# Hit animation functions that the player controller can call
func animate_hit_high_left():
	print("Punching bag hit high left!")
	if bag:
		# Apply additional impulse for visual effect
		bag.apply_central_impulse(Vector3(-2, 0, -1))

func animate_hit_high_right():
	print("Punching bag hit high right!")
	if bag:
		# Apply additional impulse for visual effect
		bag.apply_central_impulse(Vector3(2, 0, -1))

func animate_hit_low_left():
	print("Punching bag hit low left!")
	if bag:
		# Apply additional impulse for visual effect
		bag.apply_central_impulse(Vector3(-2, -0.5, -1))

func animate_hit_low_right():
	print("Punching bag hit low right!")
	if bag:
		# Apply additional impulse for visual effect
		bag.apply_central_impulse(Vector3(2, -0.5, -1))
