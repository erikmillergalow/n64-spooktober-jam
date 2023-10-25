extends Area3D

var moving = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite3D.animation = 'default'
	$AnimatedSprite3D.frame = randi() % 7


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (moving):
		global_transform.origin += global_transform.basis.z * 40 * delta


func get_damage():
	return 10


func _on_body_entered(body):
	moving = false
	$AnimatedSprite3D.animation = 'collide'
	$AnimatedSprite3D.sprite_frames.set_animation_loop('collide', false)
	$AnimatedSprite3D.play()
	
	print(body)
	if body.is_in_group('monsters'):
		body.take_damage(10)


func _on_animated_sprite_3d_animation_finished():
	if $AnimatedSprite3D.animation == 'collide':
		queue_free()


func _on_area_entered(area):
	moving = false
	$AnimatedSprite3D.animation = 'collide'
