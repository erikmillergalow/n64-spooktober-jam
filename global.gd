extends Node

# player values
var player_health = 100
var player_exp = 100000.0
var double_blaster = false
var shield_reflect = false
var spell_speed_modifier = 1
var spell_power_modifier = 1
var run_speed_modifier = 10
var has_key = false

# game states
var paused = false
var win = false
var done = false

# settings
var invert = false
var quality = false
var music_volume = 100
var fx_volume = 100

func initialize():
	global.player_health = 1000
	global.player_exp = 0
	global.double_blaster = false
	global.shield_reflect = false
	global.spell_speed_modifier = 1
	global.spell_power_modifier = 1
	global.run_speed_modifier = 15
	global.has_key = false
	global.done = false
