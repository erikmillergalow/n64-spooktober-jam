extends CharacterBody3D

const SPEED = 17
const GROUND_LERP = .1

var dead = false

@onready var global = get_node('/root/global')

# HUD
@onready var health_bar = $Control/HealthBar
@onready var inner_health_bar = $Control/HealthBar/InnerHealthBar
@onready var hit_animation = $HitAnimation
@onready var exp_label = $Control/ExpLabel
@onready var win_label = $Control/WinLabel
@onready var dead_label = $Control/DeadLabel

var knockback = Vector3(0, 0, 0)

var carrying_crate = false
@onready var carried_crate = $ShieldPivot/CarriedCrate
@onready var crate_cast = $player_spooky/CrateCast
var player_crate

# camera
@onready var spring_arm = $CamRoot/h/v/SpringArm3D
@onready var h = $CamRoot/h
@onready var v = $CamRoot/h/v

# shield
@onready var shield = $ShieldPivot/Shield
@onready var energy_shield = $ShieldPivot/EnergyShield
@onready var shield_pivot = $ShieldPivot

@onready var magic_cooldown = $MagicCooldown

@onready var animation_player = $player_spooky/AnimationPlayer

@onready var projectile_scene = load("res://projectile/projectile.tscn")


func _ready():
#	energy_shield.play()
	spring_arm.add_excluded_object(self)
	pass

func _process(_delta):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed('zoom'):
		if spring_arm.spring_length == 12:
			spring_arm.spring_length = 7#lerp(spring_arm.spring_length, 7.0, 0.4)
		elif spring_arm.spring_length == 7:
			spring_arm.spring_length = 16
		elif spring_arm.spring_length == 16:
			spring_arm.spring_length = 12
		else:
			spring_arm.spring_length = 12#lerp(spring_arm.spring_length, 12.0, 0.4)
			
	if Input.is_action_just_pressed("buy_health") and not dead:
		if global.player_health < 100.0 and global.player_exp >= 1000:
			global.player_health = clamp( global.player_health + 50.0, 0.0, 100.0)
			health_bar.value = clamp(health_bar.value + 50.0, 0.0, 100.0)
			$HealingParticles2.emitting = true
			global.player_exp -= 1000
	
	if Input.is_action_just_pressed('interact'):

		if crate_cast.is_colliding() and not carrying_crate:
			if crate_cast.get_collider().is_in_group('crates'):
				player_crate = crate_cast.get_collider()
				player_crate.grab_crate()
				carried_crate.scale = player_crate.scale
				carried_crate.visible = true
				carried_crate.monitorable = true
				carrying_crate = true
		elif carrying_crate:
			drop_crate()

func drop_crate():
	var position = carried_crate.global_transform.origin
	var rotation = carried_crate.global_rotation
	position.y = 0.0
	player_crate.place_crate(position, rotation)
	carried_crate.visible = false
	carried_crate.monitorable = false
	carrying_crate = false

func sync_spell_speed():
	var expected_cooldown = 0.435 - (0.05 * ((global.spell_speed_modifier * 2) - 1))
	if $MagicCooldown.wait_time != expected_cooldown:
		print('sync cooldown')
		print($MagicCooldown.wait_time)
		print(expected_cooldown)
		$MagicCooldown.wait_time = expected_cooldown
	
#	if global.increase_spell_speed:
#		$MagicCooldown.wait_time -= 0.05
#		global.increase_spell_speed = false


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


func play_boss_music():
	if not $BossMusic.playing:
		$Music.stop()
		$BossMusic.play()

func play_win_music():
	if not $WinMusic.playing:
		$Music.stop()
		$WinMusic.play()

func stop_music():
	$Music.stop()


func add_exp(amount):
	global.total_run_exp += amount * 3
	global.player_exp += amount * 3


func take_damage(amount):
	if not hit_animation.is_playing():
		if carrying_crate:
			drop_crate()
		
		if not dead:
			$Oof.play()
		global.player_health -= amount
		health_bar.value -= amount
		hit_animation.play("hit_flicker")
		if global.player_health <= 0.0:
			$Music.stop()
			if not $PerishedSong.is_playing():
				$PerishedSong.play()
			dead = true


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


func _input(event):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * global.mouse_camera_sensitiviy
		$CamRoot/h.rotate(Vector3.DOWN, camera_rotation.x)
		if global.invert:
			$CamRoot/h/v.rotate(Vector3.RIGHT, -camera_rotation.y)
		else:
			$CamRoot/h/v.rotate(Vector3.RIGHT, camera_rotation.y)
			
		if Input.is_action_pressed('shield'):
			print(camera_rotation.x)
			shield_pivot.rotate(Vector3.DOWN, camera_rotation.x)


func set_time_label():
	var seconds = fmod(global.elapsed_time, 60)
	var minutes = fmod(global.elapsed_time, 3600) / 60
#	var milliseconds = (fmod(global.elapsed_time , 1) * 1000) / 10 
#	var elapsed = "%02d : %02d : %02d" % [minutes, seconds, milliseconds]
	var elapsed = "%02d : %02d" % [minutes, seconds]
	$Control/TimeLabel.text = elapsed


func _physics_process(delta):

	if not dead:
		global.elapsed_time += delta
		set_time_label()
		
		sync_spell_speed()
		
		exp_label.text = "%s EXP" % global.player_exp
		
		if Input.is_action_just_pressed("start"):
			global.paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
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
		
		if Input.is_action_pressed("strafe"):
#			if h.rotation_degrees.y != $player_spooky.rotation.y:
#			h.rotation.y = lerp(h.rotation.y, $player_spooky.rotation.y, 0.25)
			$player_spooky.rotation.y = h.rotation.y #lerp($player_spooky.rotation.y, h.rotation.y, 0.25)
		
		# handle movement
		if direction != Vector3(0, 1, 0):
			animation_player.play('run', -1, 1 + abs(velocity.length()) / 17)
			
			velocity.x = lerp(velocity.x, -direction.x * (SPEED + global.run_speed_modifier * 3), GROUND_LERP)
			velocity.z = lerp(velocity.z, -direction.z * (SPEED + global.run_speed_modifier * 3), GROUND_LERP)
			
			if not Input.is_action_pressed('strafe'):
				shield_pivot.rotation.y = atan2(velocity.x, velocity.z)
			
			if not Input.is_action_pressed('strafe'):
				$player_spooky.rotation.y = lerp_angle($player_spooky.rotation.y, atan2(velocity.x, velocity.z), 1)
		else:
			velocity.x = lerp(velocity.x, 0.0, GROUND_LERP)
			velocity.z = lerp(velocity.z, 0.0, GROUND_LERP)
		
		# handle camera movement
		if cam_direction and (not Input.is_action_pressed('shield')):
			h.rotation_degrees.y -= cam_direction.x * global.horizontal_cam_speed
			if global.invert:
				v.rotation_degrees.x -= cam_direction.z * global.horizontal_cam_speed
			else:
				v.rotation_degrees.x += cam_direction.z * global.horizontal_cam_speed
			v.rotation_degrees.x = clamp(v.rotation_degrees.x, -15.0, 180.0)
		
		# handle shield movement
		if cam_direction != Vector3(0, 1, 0) and Input.is_action_pressed('shield'):
			if Input.is_action_pressed('strafe'):
				var converted = Vector3(cam_direction.x, 1, cam_direction.z).rotated(Vector3.UP, h.rotation.y)
				shield_pivot.rotation.y = atan2(-converted.x, -converted.z)
			else:
				var converted = Vector3(cam_direction.x, 1, cam_direction.z).rotated(Vector3.UP, h.rotation.y)
				shield_pivot.rotation.y = atan2(-converted.x, -converted.z) 
		elif cam_direction == Vector3(0, 1, 0) and Input.is_action_pressed('shield'):
			if Input.is_action_pressed('strafe'):
				shield_pivot.rotation.y = $player_spooky.rotation.y
		
		# handle magic attack
		if (Input.is_action_pressed('magic') and not Input.is_action_pressed('shield')) and magic_cooldown.is_stopped() and not carrying_crate:
			$Cast.pitch_scale = 1.0 + randf()
			$Cast.play()
			
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
		else:
			shield.visible = false
			shield.monitorable = false
			
		if abs(velocity.x) <= 1.0 and abs(velocity.z) <= 1.0:
			animation_player.play('idle')
			
#		velocity.y = 0.0
		move_and_slide()
		
	else:
		$player_spooky.rotation.x = lerp(rotation_degrees.x, 90.0, 0.2)
		velocity = Vector3.ZERO
		v.rotation = lerp(v.rotation, Vector3(PI/2, 0.0, 0.0) , 0.008)
		h.rotation = lerp(h.rotation, Vector3(0.0, PI/2, 0.0) , 0.008)
		spring_arm.spring_length = lerp(spring_arm.spring_length, 60.0, 0.008)
		dead_label.visible = true
		
		if Input.is_action_just_pressed("start"):
			get_tree().change_scene_to_file('res://main.tscn')
		


func _on_boss_music_finished():
	if not global.win and not dead:
		$BossMusic.play()


func _on_music_finished():
	if not dead and not $BossMusic.is_playing():
		$Music.play()


func _on_win_music_finished():
	$WinMusic.play()
