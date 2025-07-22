extends CanvasLayer

@onready var player = get_parent().get_node("Player")


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Climbing.visible = player.is_climbing
	$Driving.visible = player.is_driving
	$Fishing.visible = player.is_holding_fishing_rod
	$Flying.visible = player.is_flying
	$Hanging.visible = player.is_hanging
	$Rifling.visible = player.is_holding_rifle
	$Skateboarding.visible = player.is_skateboarding
	$Swimming.visible = player.is_swimming
