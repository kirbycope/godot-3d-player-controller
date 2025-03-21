extends Control

@onready var option_fsr = $Container/FSR
@onready var option_fxaa = $Container/FXAA
@onready var option_msaa = $Container/MSAA
@onready var option_ssaa = $Container/SSAA
@onready var option_ssrl = $Container/SSRL
@onready var option_taa = $Container/TAA
@onready var option_vsync = $Container/VSYNC
@onready var project_fsr = ProjectSettings.get_setting("rendering/scaling_3d/mode")
@onready var project_fxaa = ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa")
@onready var project_msaa = ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d")
@onready var project_ssaa = ProjectSettings.get_setting("rendering/scaling_3d/scale")
@onready var project_ssrl = ProjectSettings.get_setting("rendering/anti_aliasing/screen_space_roughness_limiter/enabled")
@onready var project_taa = ProjectSettings.get_setting("rendering/anti_aliasing/quality/use_taa")
@onready var project_vsync = ProjectSettings.get_setting("display/window/vsync/vsync_mode")
@onready var project_rendering_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:

	# Check if the [pause] action _pressed_ and the emotes node is not visible
	if event.is_action_pressed("start"):

		# Go back to the pause menu
		_on_back_button_pressed()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# By default, hide anything not for all renderers
	option_fxaa.visible = false
	option_ssrl.visible = false
	option_taa.visible = false
	option_fsr.visible = false
	
	# Vsync - This is available in all renderers.
	option_vsync.button_pressed = project_vsync

	# Multisample antialiasing (MSAA) - This is available in all renderers.
	option_msaa.selected = project_msaa

	# Supersample antialiasing (SSAA) - This is available in all renderers.
	if project_ssaa == 1.0:
		option_ssaa.selected = 0
	elif project_ssaa == 1.5:
		option_ssaa.selected = 1
	elif project_ssaa == 2.0:
		option_ssaa.selected = 2

	# Check if the rendering method if "Forward+" or "Mobile"
	if project_rendering_method == "forward_plus" or project_rendering_method == "mobile":

		# Fast approximate antialiasing (FXAA) - This is only available in the Forward+ and Mobile renderers, not the Compatibility renderer.
		option_fxaa.visible = true
		option_fxaa.button_pressed = project_fxaa

		# Screen-space roughness limiter - This is only available in the Forward+ and Mobile renderers, not the Compatibility renderer.
		option_ssrl.visible = true
		option_ssrl.button_pressed = project_ssrl

	# Check if the rendering method is "Forward+"
	if project_rendering_method == "forward_plus":

		# Temporal antialiasing (TAA) - This is only available in the Forward+ renderer, not the Mobile or Compatibility renderers.
		option_taa.visible = true
		option_taa.button_pressed = project_taa

		# AMD FidelityFX Super Resolution 2.2 (FSR2) - This is only available in the Forward+ renderer, not the Mobile or Compatibility renderers.
		option_fsr.visible = true
		option_fsr.selected = project_fsr


## Change the VSYNC value.
func _on_vsync_toggled(toggled_on: bool) -> void:

	# Check if the VSYNC option is toggled on
	if toggled_on:

		# Enable VYSNC
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

	# The VSYNC option is toggled off
	else:

		# Disable VYSNC
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


## Change the MSAA value.
func _on_msaa_item_selected(index: int) -> void:

	# Map index to MSAA values: 0=Off, 1=2x, 2=4x, 3=8x
	var msaa_values = [
		RenderingServer.VIEWPORT_MSAA_DISABLED,
		RenderingServer.VIEWPORT_MSAA_2X,
		RenderingServer.VIEWPORT_MSAA_4X,
		RenderingServer.VIEWPORT_MSAA_8X,
	]

	# Apply to the current viewport
	get_viewport().set_msaa_3d(msaa_values[index])


## Change the SSAA value.
func _on_ssaa_item_selected(index: int) -> void:

	# Map index to scale factors: 0=Off (1.0), 1=1.5 (2.25× SSAA), 2=2.0 (4× SSAA)
	var scale_factors = [
		1.0,
		1.5,
		2.0,
	]

	# Get the current viewport
	var viewport = get_viewport()

	# Set the 3D scaling mode to bilinear (0)
	viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR

	# Apply the 3D scaling factor for SSAA
	viewport.scaling_3d_scale = scale_factors[index]


## Change the FXAA value.
func _on_fxaa_toggled(toggled_on: bool) -> void:

	# Get the current viewport
	var viewport = get_viewport()

	# Check if the FXAA option is toggled on
	if toggled_on:

		# Enable FXAA
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

	# The FXAA option is toggled off
	else:

		# Disable FXAA
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED


## Change the SSRL value.
func _on_ssrl_toggled(toggled_on: bool) -> void:

	# Set the screen-space roughness limiter
	RenderingServer.screen_space_roughness_limiter_set_active(toggled_on, 0.25, 0.18)


## Change the TAA value.
func _on_taa_toggled(toggled_on: bool) -> void:

	# Get the current viewport
	var viewport = get_viewport()

	# Apply the Temporal Anti-Aliasing setting
	viewport.use_taa = toggled_on


## Change the FSR value.
func _on_fsr_item_selected(index: int) -> void:

	# Get the current viewport
	var viewport = get_viewport()

	# Apply the FSR mode based on the selected index
	viewport.scaling_3d_mode = index


## Close the settings menu.
func _on_back_button_pressed() -> void:

	# Hide the settings menu
	visible = false

	# Show the pause menu
	player.menu_pause.visible = true
