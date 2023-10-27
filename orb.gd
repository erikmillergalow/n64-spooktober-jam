extends Area3D

var exp_amount = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite3D.animation = 'default'
	$AnimatedSprite3D.frame = randi() % 7


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group('player'):
		body.add_exp(exp_amount)
		queue_free()
