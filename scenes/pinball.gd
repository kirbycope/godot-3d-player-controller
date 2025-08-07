extends RigidBody3D

# This is a dupe of settings.gd::project_rendering_method but that's tied to the player
# and I want the pinball to be more self contained.
@onready var project_rendering_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
@onready var reflection_probe: ReflectionProbe = $ReflectionProbe


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if the rendering method is not "Forward+"
	if project_rendering_method != "forward_plus":
		# Hide reflection probe because rendering method is not Forward+
		reflection_probe.hide()
