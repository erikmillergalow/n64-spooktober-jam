extends CharacterBody3D

var speed = 10.0

var angry = false
var dead = false

var health = 100.0
var max_health = 100.0
var color = Color().from_hsv(0.0, 0.0, 0.68, 1.0)
var knockback = Vector3(0, 0, 0)

var damage_modifier = 1.0

var detected_player

var player_in_proximity = false
var player_hittable = false

@onready var orb_scene = load('res://orb.tscn')
var orbs = 5

@onready var flameball_scene = load('res://flame_ball/flameball.tscn')

func _ready():
	detected_player = get_parent().get_node('Player')
	
	var unique_material = $Cube.get_surface_override_material(0).duplicate()
	$Cube.set_surface_override_material(0, unique_material)
	
	var x = randf()
	if (x < 0.25):
		velocity = Vector3(speed, 0, 0)
	elif (x < 0.50):
		velocity = Vector3(-speed, 0, 0)
	elif (x < 0.75):
		velocity = Vector3(0, 0, speed)
	else:
		velocity = Vector3(0, 0, -speed)


func set_speed(value):
	speed = value


func set_damage_modifier(modifier):
	damage_modifier = modifier


func set_orbs(amount):
	orbs = amount


func set_health(amount):
	health = amount
	max_health = amount


func set_intensity(level):
	if level == 0:
		set_orbs(20)
		set_health(100.0)
		var chance = randf()
		if chance < 0.33:
			set_damage_modifier(1.0)
		elif chance < 0.66:
			set_damage_modifier(2.0)
		else:
			set_damage_modifier(3.0)
			
		var speed_chance = randf()
		if speed_chance < 0.5:
			set_speed(10.0)
		else:
			set_speed(15.0)
			
	if level == 1:
		set_orbs(20)
		set_health(150.0)
		var chance = randf()
		if chance < 0.33:
			set_damage_modifier(1.0)
		elif chance < 0.66:
			set_damage_modifier(2.0)
		else:
			set_damage_modifier(3.0)
			
		var speed_chance = randf()
		if speed_chance < 0.5:
			set_speed(10.0)
		else:
			set_speed(15.0)
			
	if level == 2:
		set_orbs(50)
		set_health(2500.0)
		var chance = randf()
		if chance < 0.33:
			set_damage_modifier(1.0)
		elif chance < 0.95:
			set_damage_modifier(2.0)
		else:
			set_damage_modifier(3.0)
			
		var speed_chance = randf()
		if speed_chance < 0.5:
			set_speed(9.0)
		else:
			set_speed(14.0)

	if level == 3:
		set_orbs(70)
		set_health(500.0)
		var chance = randf()
		if chance < 0.22:
			set_damage_modifier(1.0)
		elif chance < 0.80:
			set_damage_modifier(2.0)
		else:
			set_damage_modifier(3.0)
			
		var speed_chance = randf()
		if speed_chance < 0.8:
			set_speed(8.0)
		else:
			set_speed(16.0)


func set_detected_player(body):
	pass


func is_player_near():
	player_in_proximity = global_transform.origin.distance_to(detected_player.global_transform.origin) < 100.0


func is_player_hittable():
	if player_in_proximity:
		if floor(int(transform.origin.x + 150) / 100) == floor(int(detected_player.global_transform.origin.x + 150) / 100):
			if floor(int(transform.origin.z + 50) / 100) == floor(int(detected_player.global_transform.origin.z + 50) / 100):
				player_hittable = true
			else:
				player_hittable = false
		else:
			player_hittable = false


func _process(delta):
	
	# preserve resources for better performance by disabling actions when player is far away
	is_player_near()
	is_player_hittable()
	
	if player_in_proximity:
		if not angry and not dead:
			velocity = lerp(velocity, $Cube.transform.basis.z * speed, 0.2)

			# THIS ONE
			$Cube.rotation.y = lerp_angle($Cube.rotation.y, atan2(velocity.x, velocity.z), 1)
	#		$Cube.rotation.y = atan2(velocity.x, velocity.z)

			var turn_chance = randf()
			if turn_chance > 0.98:
				var turn_amount = randf() * ((PI/2))
				velocity = velocity.rotated(Vector3(0, 1, 0), (PI/2) - turn_amount)
				
		if angry and not dead:
			$Cube.rotation.y = PI
			# move toward player
			var direction = (detected_player.transform.origin - transform.origin).normalized();
			
			look_at(detected_player.global_transform.origin, Vector3.UP)
			
			if not $Dance.is_playing():
				velocity = lerp(velocity, direction * speed, 0.3)
			
			if player_in_proximity and player_hittable and $FlameCooldown.is_stopped():
				var flameball = flameball_scene.instantiate()
				flameball.transform.origin = global_transform.origin - Vector3(0.0, -0.5, 0.0)
				flameball.rotation.y = rotation.y + PI
				flameball.rotation.x = 0
				get_parent().add_child(flameball)
				$FlameCooldown.start()


func _physics_process(delta):
	if player_in_proximity:

		knockback = lerp(knockback, Vector3.ZERO, 0.5)
		velocity += knockback

		velocity.y = 0

		var collision = move_and_collide(velocity * delta)
		if collision:

			if (collision.get_collider().is_in_group('player')):

				if not angry:
					$FlameCooldown.start()
					angry = true

				var player = collision.get_collider()
				player.add_knockback(-global_transform.basis.z * (damage_modifier) * 2)
				player.take_damage(10 + (5 * damage_modifier))
				$Dance.play('dance')

	#		if (collision.get_collider().is_in_group('walls_objects')):
			var reflect = collision.get_remainder().bounce(collision.get_normal())
			velocity = velocity.bounce(collision.get_normal())
			move_and_collide(reflect)

		if dead:
			rotation_degrees.x = lerp(rotation_degrees.x, 90.0, 0.2)
			velocity = Vector3.ZERO


func add_knockback(direction):
	if not dead and player_in_proximity:
		direction.y = 0
		knockback = direction * 15.0


func spawn_at_location(location):
	global_transform.origin = location

func take_damage(amount):
	if not angry:
		$FlameCooldown.start()
		angry = true
	
	health -= amount 
	
	var current_sat = $Cube.get_surface_override_material(0).albedo_color.s
	var new_color = Color().from_hsv(0.0, 1.0 - health / max_health, 0.60, 1.0)
	$Cube.get_surface_override_material(0).albedo_color = new_color
	
	if health <= 0:
		if not dead:
			for i in range(0, orbs):
				var orb = orb_scene.instantiate()
				orb.transform.origin = global_transform.origin + Vector3(randf() * 3, 1, randf() * 3)
				get_parent().add_child(orb)
		
		dead = true
		velocity = Vector3(0, 0, 0)
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)


func _on_flame_cooldown_timeout():
	if not dead and player_in_proximity and player_hittable:
		var flameball = flameball_scene.instantiate()
		flameball.set_damage_modifier(damage_modifier)
		flameball.transform.origin = global_transform.origin - Vector3(0.0, -0.5, 0.0)
		flameball.rotation.y = rotation.y + PI
		flameball.rotation.x = 0
		get_parent().add_child(flameball)
		$FlameCooldown.start()
