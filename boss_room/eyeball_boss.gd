extends CharacterBody3D


var speed = 10.0

var health = 2000.0
var max_health = 2000.0

var active = false
var dead = false
var player

var knockback = Vector3.ZERO

@onready var flameball_scene = load('res://flame_ball/flameball.tscn')


func _ready():
	pass


func set_player(body):
	player = body


func _physics_process(delta):
	if not dead:
		$Arm.rotation.x = lerp($Arm.rotation.x, $Arm.rotation.x + 0.05, 0.8)
		$Arm2.rotation.x = lerp($Arm2.rotation.x, $Arm2.rotation.x + 0.05, 0.8)
	
	
	if active and not dead and not $SpinBlast.is_playing():
		rotation.y = PI
		
		# move toward player
		var direction = (player.global_transform.origin - global_transform.origin).normalized();
		direction.y = 0
		look_at(player.global_transform.origin, Vector3.UP)
		
		velocity = lerp(velocity, direction * speed, 0.3)
		
#		print($SpinTimer.is_stopped())
		if $SpinTimer.is_stopped() and not $SpinBlast.is_playing():
			if randf() > 0.6:
				$SpinTimer.start()
				$SpinBlast.play("spinblast")
				$BlastDelay.start()

	if $SpinBlast.is_playing():
		velocity = lerp(velocity, Vector3.ZERO, 0.4)
		
		
	knockback = lerp(knockback, Vector3.ZERO, 0.5)
	velocity += knockback
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if (collision.get_collider().is_in_group('player')):
			print('DETECTED')
			
			if not active:
				activate()
			
			var player = collision.get_collider()
			player.add_knockback(-global_transform.basis.z * 15)
			player.take_damage(20)
		
	if dead:
		rotation_degrees.x = lerp(rotation_degrees.x, 90.0, 0.2)
		velocity = Vector3.ZERO



func add_knockback(direction):
	if not dead:
		direction.y = 0
		knockback = direction * 3.0


func activate():
	player.play_boss_music()
	$BlastDelay.start()
	$SpinBlast.play("spinblast")
	active = true

func take_damage(amount):
	if not active:
		activate()
	
	health -= amount 
	
	var head_sat = $Head.get_active_material(0).albedo_color.s
	var new_head_color = Color().from_hsv(0.0, 1.0 - health / max_health, 0.68, 1.0)
	$Head.get_active_material(0).albedo_color = new_head_color
	
	var arm_sat = $Arm.get_active_material(0).albedo_color.s
	var new_arm_color = Color().from_hsv(0.0, 1.0 - health / max_health, 0.68, 1.0)
	$Arm.get_active_material(0).albedo_color = new_arm_color
	
	var arm2_sat = $Arm2.get_active_material(0).albedo_color.s
	var new_arm2_color = Color().from_hsv(0.0, 1.0 - health / max_health, 0.68, 1.0)
	$Arm2.get_active_material(0).albedo_color = new_arm2_color
	
	if health <= 0:
		$DestructionBlast.visible = true
		$DestructionBlast.play()
		$GrowDestruction.play('grow')
		$SpinBlast.stop()
		dead = true
		$Particles.visible = true
		$ParticlesTimer.start()


func _on_blast_delay_timeout():
	if not dead and $SpinBlast.is_playing():
		for i in range(-7, 7):
			var flameball = flameball_scene.instantiate()
			flameball.transform.origin = transform.origin - Vector3(0, 1.8 , 0.5)
			flameball.rotation.y = rotation.y + PI + ((PI / 8) * i)
			flameball.rotation.x = 0
			get_parent().add_child(flameball)
			$BlastDelay.start()


func _on_spin_blast_animation_finished(anim_name):
	print('spin anim finished')
	$SpinBlast.stop()
	$SpinTimer.start()


func _on_arm_2_area_3d_body_entered(body):
	if body.is_in_group('player'):
		if not active:
			activate()

		body.add_knockback(-global_transform.basis.z * 10)
		body.take_damage(20)


func _on_arm_area_3d_body_entered(body):
	if body.is_in_group('player'):
		if not active:
			activate()

		body.add_knockback(-global_transform.basis.z * 10)
		body.take_damage(20)


func _on_particles_timer_timeout():
	$Particles.visible = false
	$DeadTimer.start()


func _on_dead_timer_timeout():
	global.win = true
