extends CharacterBody3D

const SPEED = 10.0
var WEIGHT = 1.0

var angry = false
var dead = false

var health = 100
var color = Color().from_hsv(0.0, 0.0, 0.68, 1.0)
var knockback = Vector3(0, 0, 0)

var new_look = 0

var detected_player

@onready var orb_scene = load('res://orb.tscn')
var orbs = 5

@onready var flameball_scene = load('res://flame_ball/flameball.tscn')

func _ready():
	var unique_material = $Cube.get_surface_override_material(0).duplicate()
	$Cube.set_surface_override_material(0, unique_material)
	
	var x = randf()
	if (x < 0.25):
		velocity = Vector3(SPEED, 0, 0)
	elif (x < 0.50):
		velocity = Vector3(-SPEED, 0, 0)
	elif (x < 0.75):
		velocity = Vector3(0, 0, SPEED)
	else:
		velocity = Vector3(0, 0, -SPEED)


func _on_cooldown_timeout():
	if not dead:
		var flameball = flameball_scene.instantiate()
		flameball.global_transform.origin = global_transform.origin - Vector3(0, -0.5, 0.5)
		flameball.rotation.y = $Cube.rotation.y
		flameball.rotation.x = 0
		owner.add_child(flameball)
		$FlameCooldown.start()
	

func _physics_process(delta):
	if not angry and not dead:
		# if not angry just hang out and look around
		velocity = lerp(velocity, Vector3.ZERO, 0.2)
		
		$Cube.rotation.y = lerp_angle($Cube.rotation.y, new_look, 0.15)
		
		var turn_chance = randf()
		if turn_chance > 0.985:
			var turn_amount = randf() * ((PI))
			new_look = $Cube.rotation.y + turn_amount

	if angry:
		$FlameCooldown.start()
		print(global_transform.origin.distance_to(detected_player.global_transform.origin))
		if global_transform.origin.distance_to(detected_player.global_transform.origin) < 6:
			if $TwirlCooldown.is_stopped():
				$TwirlAttack.visible = true
				$TwirlAttack.play('default')
				$TwirlCooldown.start()
		

	knockback = lerp(knockback, Vector3.ZERO, 1.0)
	velocity += knockback
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal())
		move_and_collide(reflect)
		
	if dead:
		rotation_degrees.x = lerp(rotation_degrees.x, 90.0, 0.2)
		velocity = Vector3.ZERO


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



func _on_twirl_attack_animation_finished():
	$TwirlAttack.visible = false
