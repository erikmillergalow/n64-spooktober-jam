extends Area3D

var moving = true
var speed = 25
var reflected = false
var damage_modifier = 1

@onready var global = get_node("/root/global")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite3D.animation = 'default'
	$AnimatedSprite3D.frame = randi() % 7


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (moving):
		global_transform.origin += global_transform.basis.z * speed * delta


func set_damage_modifier(damage_modifier):
	damage_modifier = damage_modifier
	$AnimatedSprite3D.pixel_size += (damage_modifier * 0.001)


func reflect(body):
	print('reflect')
	global_transform.basis.z = body.global_transform.basis.z

func _on_body_entered(body):
	if body.is_in_group('walls_objects'):
		moving = false
		$AnimatedSprite3D.animation = 'collide'
		$AnimatedSprite3D.pixel_size += (damage_modifier * 0.009)
#		queue_free()
		
	if body.is_in_group('player'):
		moving = false
		$AnimatedSprite3D.animation = 'collide'
		$AnimatedSprite3D.pixel_size += (damage_modifier * 0.009)
		body.add_knockback(global_transform.basis.z.normalized())
		body.take_damage(5)
#		queue_free()
	
	if body.is_in_group('monsters') and reflected:
		moving = false
		$AnimatedSprite3D.animation = 'collide'
		$AnimatedSprite3D.pixel_size += (damage_modifier * 0.009)
		body.add_knockback(global_transform.basis.z.normalized())
		body.take_damage(5)
#		queue_free()


func _on_area_entered(area):
	if area.is_in_group('player_shield'):
		print('shield hit')
		if global.shield_reflect:
			reflected = true
			global_transform.basis.z = area.global_transform.basis.z
		else:
			moving = false
			$AnimatedSprite3D.animation = 'collide'
			$AnimatedSprite3D.pixel_size += (damage_modifier * 0.009)
#			queue_free()


func _on_animated_sprite_3d_animation_finished():
	if $AnimatedSprite3D.animation == 'collide':
		queue_free()