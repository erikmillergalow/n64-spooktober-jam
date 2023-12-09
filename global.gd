extends Node

# player values
var player_health = 100.0
var player_exp = 0.0
var total_run_exp = 0.0
var double_blaster = false
var shield_reflect = false
var spell_speed_modifier = 1.0
var spell_power_modifier = 1.0
var run_speed_modifier = 1.0
var has_key = false
var increase_spell_speed = false
var room_rows = 3
var room_cols = 3
var max_stats_level = 1.0
var challenge_start = false
var challenge_options_open = false
var seed

var horizontal_cam_speed = 2.0
var mouse_camera_sensitiviy = 0.01

# game states
var paused = false
var win = false
var done = false
var elapsed_time = 0

# settings
var invert = false
var quality = false
var music_volume = 100
var fx_volume = 100
var maze_mode = true
var grid_size = 1

var apiKey = ""
func _ready():
	var f = FileAccess.open('res://apiKey.env', FileAccess.READ)
	self.apiKey = f.get_line()
	f.close()
	
	SilentWolf.configure({
		"api_key": apiKey,
		"game_id": "super_monster_smash_64",
		"log_level": 1
	})

func initialize():
	global.total_run_exp = 0
	global.elapsed_time = 0
	global.max_stats_level = 1.0
	global.increase_spell_speed = false
	global.player_health = 100000.0
	global.player_exp = 0
	global.double_blaster = false
	global.shield_reflect = false
	global.spell_speed_modifier = 1.0
	global.spell_power_modifier = 20.0
	global.run_speed_modifier = 10.0
	global.has_key = false
	global.done = false
	global.win = false
