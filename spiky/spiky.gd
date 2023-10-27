extends CharacterBody3D

const speed = 8.0
var weight = 1.0

var angry = false
var dead = false

var health = 100
var color = Color().from_hsv(0.0, 0.0, 0.68, 1.0)
var knockback = Vector3(0, 0, 0)

var new_look = 0

var detected_player

var damage_modifier = 1.0

@onready var orb_scene = load('res://orb.tscn')
var orbs = 5

@onready var flameball_scene = load('res://flame_ball/flameball.tscn')

func _ready():
	var unique_material = $Cube.get_surface_override_material(0).duplicate()
	$Cube.set_surface_override_material(0, unique_material)
	
#	var x = randf()
#	if (x < 0.25):
#		velocity = Vector3(SPEED, 0, 0)
#	elif (x < 0.50):
#		velocity = Vector3(-SPEED, 0, 0)
#	elif (x < 0.75):
#		velocity = Vector3(0, 0, SPEED)
#	else:
#		velocity = Vector3(0, 0, -SPEED)


func _physics_process(delta):
	if not angry and not dead:
		# if not angry just hang out and look around
		velocity = lerp(velocity, Vector3.ZERO, 0.2)
		
		$Cube.rotation.y = lerp_angle($Cube.rotation.y, new_look, 0.15)

		var turn_chance = randf()
		if turn_chance > 0.985:
			var turn_amount = randf() * ((PI))
			new_look = $Cube.rotation.y + turn_amount

	if angry and not dead:
		$Cube.rotation.y = PI
		# move toward player
		var direction = (detected_player.transform.origin - transform.origin).normalized();
		
		look_at(detected_player.global_transform.origin, Vector3.UP)
		
		if $TwirlCooldown.is_stopped() or $TwirlAttack.visible:
			velocity = lerp(velocity, direction * speed, 0.3)
		else:
			velocity = lerp(velocity, -direction * speed, 0.3)
		

		if global_transform.origin.distance_to(detected_player.global_transform.origin) < 6:
			if $TwirlCooldown.is_stopped():
				$TwirlAttack.visible = true
				$TwirlAttack.play('default')
				$TwirlCooldown.start()
				$TwirlHitBox.monitorable = true
				$TwirlHitBox.monitoring = true
		

	knockback = lerp(knockback, Vector3.ZERO, 0.5)
	velocity += knockback
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal())
		move_and_collide(reflect)
		
	if dead:
		rotation_degrees.x = lerp(rotation_degrees.x, 90.0, 0.2)
		velocity = Vector3.ZERO


func _on_twirl_hit_box_body_entered(body):
	if body.is_in_group('player'):
		print('player hit')
		body.add_knockback(-global_transform.basis.z * (damage_modifier) * 5)		
		body.take_damage(10 + (5 * damage_modifier))


func _on_twirl_attack_animation_finished():
	$TwirlHitBox.monitorable = false
	$TwirlHitBox.monitoring = false
	$TwirlAttack.visible = false


func add_knockback(direction):
	if not dead:
		direction.y = 0
		knockback = direction * 15.0


func take_damage(amount):
	health -= amount 
	
	var current_sat = $Cube.get_surface_override_material(0).albedo_color.s
	var new_color = Color().from_hsv(0.0, current_sat + 0.1, 0.68, 1.0)
	$Cube.get_surface_override_material(0).albedo_color = new_color
	
	if health <= 0:
		dead = true
		velocity = Vector3(0, 0, 0)
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		
		for i in range(0, orbs):
			var orb = orb_scene.instantiate()
			orb.global_transform.origin = global_transform.origin + Vector3(randf() * 3, 1, randf() * 3)
			get_parent().add_child(orb)


func _on_area_3d_body_entered(body):
	print('entered spiky range')
	print(body)
	if body.is_in_group('player'):
		print('body in')
		if not angry:
			angry = true
			detected_player = body
			$FlameCooldown.start()
#			$TwirlCooldown.start()


func _on_flame_cooldown_timeout():
	if not dead:
		for i in range(-3, 3):
			var flameball = flameball_scene.instantiate()
			flameball.global_transform.origin = global_transform.origin - Vector3(0, -0.5, 0.5)
			flameball.rotation.y = rotation.y + PI + ((PI / 8) * i)
			flameball.rotation.x = 0
			owner.add_child(flameball)
			$FlameCooldown.start()
