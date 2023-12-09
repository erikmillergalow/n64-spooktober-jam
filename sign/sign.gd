extends StaticBody3D

@export_multiline var text

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group('player'):
		body.read_sign(text)


func _on_area_3d_body_exited(body):
	if body.is_in_group('player'):
		body.stop_reading()
