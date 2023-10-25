extends CharacterBody3D

const SPEED = 10.0
var WEIGHT = 1.0

var angry = false
var dead = false

var health = 100
var color = Color().from_hsv(0.0, 0.0, 0.68, 1.0)


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


func _physics_process(delta):
	if not angry and not dead:
		$Cube.rotation.y = lerp_angle($Cube.rotation.y, atan2(velocity.x, velocity.z), 1)
		
		var turn_chance = randf()
		if turn_chance > 0.98:
			var turn_amount = randf() * ((PI/2))
			velocity = velocity.rotated(Vector3(0, 1, 0), (PI/2) - turn_amount)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal())
		move_and_collide(reflect)

func _on_area_3d_body_entered(body):
	if body.is_in_group("player_projectile"):
		print(body)
		take_damage(body.get_damage())


func take_damage(amount):
	health -= amount 
	
	var current_sat = $Cube.get_surface_override_material(0).albedo_color.s
	print(current_sat)
	print($Cube.get_surface_override_material(0).albedo_color)
	var new_color = Color().from_hsv(0.0, current_sat + 0.1, 0.68, 1.0)
	print(new_color)
	$Cube.get_surface_override_material(0).albedo_color = new_color
	
	if health <= 0:
		print("dead")
		dead = true
		velocity = Vector3(0, 0, 0)



