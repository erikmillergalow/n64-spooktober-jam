extends StaticBody3D

@onready var laser_gate = $LaserGate
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func close_laser_gate():
	$LaserGate.set_collision_layer_value(1, true)
	$Gate2D.visible = true
