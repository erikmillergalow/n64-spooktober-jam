extends CharacterBody3D

const SPEED = 17
const GROUND_LERP = .1

var horizontal_cam_speed = 2

@onready var spring_arm = $CamRoot/h/v/SpringArm3D
@onready var h = $CamRoot/h
@onready var v = $CamRoot/h/v
@onready var shield = $ShieldPivot/Shield
@onready var energy_shield = $ShieldPivot/EnergyShield
@onready var shield_pivot = $ShieldPivot

@onready var animation_player = $player_spooky/AnimationPlayer

@onready var projectile_scene = load("res://projectile/projectile.tscn")
#@onready var shield_scene = load("res://shield/shield.tscn")
#var shield

# Called when the node enters the scene tree for the first time.
func _ready():
#	energy_shield.play()
	pass # Replace with function body.


func get_input_direction():
	var dx = Input.get_action_strength("right") - Input.get_action_strength('left')
	var dz = Input.get_action_strength("back") - Input.get_action_strength("forward")
	
	# account for camera's current rotation
	return Vector3(dx, 1, dz).rotated(Vector3.UP, h.rotation.y)

func get_cam_input_direction():
	var dx = Input.get_action_strength("cam_right") - Input.get_action_strength('cam_left')
	var dz = Input.get_action_strength("cam_back") - Input.get_action_strength("cam_forward")
	
	# account for camera's current rotation
	return Vector3(dx, 1, dz)#.rotated(Vector3.UP, h.rotation.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# gather inputs
	var direction = get_input_direction()
	var cam_direction = get_cam_input_direction()
	
	# handle movement
	if direction != Vector3(0, 1, 0):
		
		animation_player.play('run', -1, 1 + abs(velocity.length()) / 17)
		
		velocity.x = lerp(velocity.x, -direction.x * SPEED, GROUND_LERP)
		velocity.z = lerp(velocity.z, -direction.z * SPEED, GROUND_LERP)
		
		shield_pivot.rotation.y = atan2(velocity.x, velocity.z)
		
		$player_spooky.rotation.y = lerp_angle($player_spooky.rotation.y, atan2(velocity.x, velocity.z), 1)
	else:
		velocity.x = lerp(velocity.x, 0.0, GROUND_LERP)
		velocity.z = lerp(velocity.z, 0.0, GROUND_LERP)
	
	# handle camera movement
	if cam_direction and (not Input.is_action_pressed('shield')):
		h.rotation_degrees.y -= cam_direction.x * horizontal_cam_speed
		v.rotation_degrees.x += cam_direction.z * horizontal_cam_speed
	
	# handle shield movement
	if cam_direction != Vector3(0, 1, 0) and Input.is_action_pressed('shield'):
		shield_pivot.rotation.y = atan2(-cam_direction.x, -cam_direction.z) 
	
	# handle magic attack
	if (Input.is_action_just_pressed('magic') and not Input.is_action_pressed('shield')):
		var projectile = projectile_scene.instantiate()
		projectile.global_transform = v.global_transform
		projectile.rotation.y = $player_spooky.rotation.y
		projectile.rotation.x = 0
		owner.add_child(projectile)
		
	if (Input.is_action_pressed('shield')):
		shield.visible = true
#		energy_shield.visible = true
	else:
		shield.visible = false
#		energy_shield.visible = false
		
	if abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0:
		animation_player.play('idle')
		
	move_and_slide()
