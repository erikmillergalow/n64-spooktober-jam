extends CharacterBody3D

const SPEED = 17
const GROUND_LERP = .1

var horizontal_cam_speed = 2

@onready var global = get_node('/root/global')

@onready var health_bar = $Control/HealthBar
@onready var inner_health_bar = $Control/HealthBar/InnerHealthBar
@onready var hit_animation = $HitAnimation
@onready var exp_label = $Control/ExpLabel
@onready var win_label = $Control/WinLabel

var knockback = Vector3(0, 0, 0)

@onready var spring_arm = $CamRoot/h/v/SpringArm3D
@onready var h = $CamRoot/h
@onready var v = $CamRoot/h/v
@onready var shield = $ShieldPivot/Shield
@onready var energy_shield = $ShieldPivot/EnergyShield
@onready var shield_pivot = $ShieldPivot

@onready var magic_cooldown = $MagicCooldown

@onready var animation_player = $player_spooky/AnimationPlayer

@onready var pause_menu = $Control/PauseMenu
@onready var resume_button = $Control/PauseMenu/HBoxContainer/VBoxContainer/Resume

@onready var projectile_scene = load("res://projectile/projectile.tscn")


func _ready():
#	energy_shield.play()
	pass

func _process(delta):
	if Input.is_action_just_pressed('zoom'):
		if spring_arm.spring_length == 12:
			spring_arm.spring_length = 7#lerp(spring_arm.spring_length, 7.0, 0.4)
		else:
			spring_arm.spring_length = 12#lerp(spring_arm.spring_length, 12.0, 0.4)


func show_door_text():
	if not global.has_key:
		$Control/DoorLabel.visible = true


func hide_door_text():
	$Control/DoorLabel.visible = false


func show_key_alert():
	$Control/KeyAlertLabel.visible = true
	$Control/KeyAlertTimer.start()


func _on_key_alert_timer_timeout():
	$Control/KeyAlertLabel.visible = false


func add_exp(amount):
	global.player_exp += amount
	exp_label.text = "%s EXP" % global.player_exp


func take_damage(amount):
	print(hit_animation.is_playing())
	if not hit_animation.is_playing():
		global.player_health -= amount
		health_bar.value -= amount
		hit_animation.play("hit_flicker")


func add_knockback(direction):
	if not hit_animation.is_playing():
		direction.y = 0
		knockback = direction * 15.0

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
	
	if Input.is_action_just_pressed("start"):
		global.paused = true
		get_tree().paused = true
	
	if global.win == true:
		win_label.visible = true
		health_bar.visible = false
		exp_label.visible = false
	
	
	if (health_bar.value != global.player_health):
		health_bar.value = global.player_health
	inner_health_bar.value = lerp(inner_health_bar.value, health_bar.value, 0.05)
	
	# gather inputs
	var direction = get_input_direction()
	var cam_direction = get_cam_input_direction()
	
	velocity += knockback
	knockback = lerp(knockback, Vector3.ZERO, 1.0)
	
	# handle movement
	if direction != Vector3(0, 1, 0):
		animation_player.play('run', -1, 1 + abs(velocity.length()) / 17)
		
		velocity.x = lerp(velocity.x, -direction.x * (SPEED + global.run_speed_modifier * 3), GROUND_LERP)
		velocity.z = lerp(velocity.z, -direction.z * (SPEED + global.run_speed_modifier * 3), GROUND_LERP)
		
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
#		Vector3(dx, 1, dz).rotated(Vector3.UP, h.rotation.y)
		var converted = Vector3(cam_direction.x, 1, cam_direction.z).rotated(Vector3.UP, h.rotation.y)
		shield_pivot.rotation.y = atan2(-converted.x, -converted.z) 
	
	# handle magic attack
	if (Input.is_action_pressed('magic') and not Input.is_action_pressed('shield')) and magic_cooldown.is_stopped():
		magic_cooldown.start()
		if (global.double_blaster):
			var projectileA = projectile_scene.instantiate()
			projectileA.global_transform.origin = v.global_transform.origin - Vector3(0.5, 0, 0)
			projectileA.rotation.y = $player_spooky.rotation.y
			projectileA.rotation.x = 0
			var projectileB = projectile_scene.instantiate()
			projectileB.global_transform.origin = v.global_transform.origin + Vector3(0.5, 0, 0)
			projectileB.rotation.y = $player_spooky.rotation.y
			projectileB.rotation.x = 0
			owner.add_child(projectileA)
			owner.add_child(projectileB)
		else:
			var projectile = projectile_scene.instantiate()
			projectile.global_transform = v.global_transform
			projectile.rotation.y = $player_spooky.rotation.y
			projectile.rotation.x = 0
			owner.add_child(projectile)

		
	if (Input.is_action_pressed('shield')):
		shield.visible = true
		shield.monitorable = true
#		energy_shield.visible = true
	else:
		shield.visible = false
		shield.monitorable = false
#		energy_shield.visible = false
		
	if abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0:
		animation_player.play('idle')
		
	move_and_slide()
