extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_at_location(location):
	global_transform.origin = location


func grab_crate():
	global_transform.origin.y = -10.0


func place_crate(position, rotation):
	global_rotation = rotation
	global_transform.origin = position
