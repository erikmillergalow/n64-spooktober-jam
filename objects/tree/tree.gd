extends StaticBody3D


func _ready():
	$Sprite3D.modulate = Color(randf(), randf(), randf())


func spawn_at_location(location):
	global_transform.origin = location
