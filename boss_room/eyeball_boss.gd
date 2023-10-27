extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#var health = 5000
var health = 100


func _physics_process(delta):
	$Arm.rotation.x = lerp($Arm.rotation.x, $Arm.rotation.x + 0.05, 0.8)
	$Arm2.rotation.x = lerp($Arm2.rotation.x, $Arm2.rotation.x + 0.05, 0.8)

func add_knockback(direction):
	print('knockknock')

func take_damage(amount):
	health -= amount 
	
#	var current_sat = $Head.material.albedo_color.s
#	var new_color = Color().from_hsv(0.0, current_sat + 0.1, 0.68, 1.0)
#	$Head.material.albedo_color = new_color
	
	if health <= 0:
		global.win = true
		
