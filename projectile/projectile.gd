extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite3D.frame = randi() % 7
#	$AnimatedSprite3D.set_frame_and_progress(randi() % 7)
#	$AnimatedSprite3D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_transform.origin += global_transform.basis.z * 40 * delta
