extends Area3D

var moving = true
var damage = 10

@onready var global = get_node('/root/global')

func _ready():
	$AnimatedSprite3D.pixel_size += (global.spell_power_modifier * 0.001)
	$AnimatedSprite3D.animation = 'default'
	$AnimatedSprite3D.frame = randi() % 7


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (moving):
		global_transform.origin += global_transform.basis.z * 40 * delta


func _on_body_entered(body):
	moving = false
	$AnimatedSprite3D.pixel_size += (global.spell_power_modifier * 0.009)
	$AnimatedSprite3D.animation = 'collide'
	$AnimatedSprite3D.sprite_frames.set_animation_loop('collide', false)
	$AnimatedSprite3D.play()
	
	if body.is_in_group('monsters'):
		body.take_damage(10 + (5 * global.spell_power_modifier))
		body.add_knockback(global_transform.basis.z.normalized() * (global.spell_power_modifier))


func _on_animated_sprite_3d_animation_finished():
	if $AnimatedSprite3D.animation == 'collide':
		queue_free()


func _on_area_entered(area):
	moving = false
	$AnimatedSprite3D.animation = 'collide'
