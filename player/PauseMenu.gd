extends Control

@onready var global = get_node("/root/global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	$HBoxContainer/VBoxContainer/Resume.grab_focus()

func set_buttons():
	$ShieldUpgrade.disabled = (global.player_exp < 2000 or global.shield_reflect)
	$DoubleBlaster.disabled = (global.player_exp < 10000 or global.double_blaster)
	$SpellSpeed.disabled = global.player_exp < 1000
	$SpellStrength.disabled = global.player_exp < 1000
	$RunSpeed.disabled = global.player_exp < 1000
	$HealthUpgrade.disabled = (global.player_exp < 1000 or global.player_health == 100)


func set_labels():
	$HealthLabel.text = "Health: %s" % global.player_health
	$ExpLabel.text = "Exp: %s" % global.player_exp
	$ShieldUpgrade/ShieldLabel2.text = "Reflective: %s" % global.shield_reflect
	$DoubleBlaster/BlasterLabel2.text = "Double spells: %s" % global.double_blaster
	$SpellSpeed/SpellSpeedLabel2.text = "Level: %s" % global.spell_speed_modifier
	$SpellStrength/SpellDamageLabel2.text = "Level: %s" % global.spell_power_modifier
	$RunSpeed/RunSpeedLabel2.text = "Level: %s" % global.run_speed_modifier
	if global.has_key:
		$KeyLabel.text = "You have the key!"
	else:
		$KeyLabel.text = "Have you found the key chest? \n Not yet..."

func _process(_delta):
	set_labels()
	set_buttons()
	
	if global.paused and visible != true:
		visible = true
		$Resume.grab_focus()

func unpause():
	visible = false
	global.paused = false
	get_tree().paused = false


func _on_resume_pressed():
	unpause()


func _on_shield_upgrade_pressed():
	global.shield_reflect = true
	global.player_exp -= 2000


func _on_double_blaster_pressed():
	global.double_blaster = true
	global.player_exp -= 4000


func _on_spell_speed_pressed():
	global.spell_speed_modifier += 0.5
	global.player_exp -= 1000
	global.increase_spell_speed = true


func _on_spell_strength_pressed():
	global.spell_power_modifier += 1
	global.player_exp -= 1000


func _on_run_speed_pressed():
	global.run_speed_modifier += 1
	global.player_exp -= 1000


func _on_health_upgrade_pressed():
	global.player_health = 100
	global.player_exp -= 1000


func _on_end_run_pressed():
	global.initialize()
	unpause()
