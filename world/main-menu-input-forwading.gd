extends Control


## Called when the node enters the scene tree for the first time.
#func _ready():
#	set_process_unhandled_input(true)
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#
#
#func _input(event):
#	# fix by ArdaE https://github.com/godotengine/godot/issues/17326#issuecomment-431186323
#	for child in get_children():
#		if event is InputEventMouse:
#			var mouseEvent = event.duplicate()
#			mouseEvent.position = get_global_transform_with_canvas().affine_inverse() * event.position
#			child.unhandled_input(mouseEvent)
#		else:
#			child.unhandled_input(event)
