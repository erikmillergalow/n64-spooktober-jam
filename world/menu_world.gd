extends Node3D

var overworld_scene = preload('res://overworld/overworld.tscn')

@onready var global = get_node("/root/global")

var helpIndex = 0
@onready var helpLabels = [
	$Control/HelpRect/Controls,
	$Control/HelpRect/KeyboardControls,
	$Control/HelpRect/Upgrades,
	$Control/HelpRect/Monsters,
	$Control/HelpRect/Premise,
	$Control/HelpRect/Mechanics,
	$Control/HelpRect/Modes
]


func _ready():
	$Title/AnimationPlayer.play('zoom')
	$Control/BeginButton.grab_focus()
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#	$Control.grab_focus()
	randomize()
	global.seed = str(randi())
	$Control/GridSizeRect/SeedTextEdit.text = global.seed
	$Control/SettingsRect/MouseLookSlider.value = global.mouse_camera_sensitiviy
	$Control/SettingsRect/FXSlider.value = global.fx_volume
	$Control/SettingsRect/MusicSlider.value = global.music_volume
	$Control/SettingsRect/InvertCheck.button_pressed = global.invert
#	$Control/SettingsRect/QualityCheck.button_pressed = !global.quality


func _process(_delta):
	$Floor.mesh.material.uv1_offset.z -= 0.03
	$WorldEnvironment.environment.sky_rotation.y -= 0.002
	
	if global.challenge_start:
		global.challenge_start = false
		start_game()


func _on_begin_button_pressed():
#	$Control/GridSizeRect/RowsSlider.value = global.room_rows
#	$Control/GridSizeRect/ColsSlider.value = global.room_cols
	$Control/GridSizeRect/MazeModeCheckbox.button_pressed = global.maze_mode
	$Control/GridSizeRect.visible = true
	$Control/GridSizeRect/GridSizeSlider.value = 1
	$Control/GridSizeRect/GridSizeSlider.grab_focus()

# game config menu
func _on_rows_slider_value_changed(value):
	global.room_rows = value


func _on_cols_slider_value_changed(value):
	global.room_cols = value


func start_game():
	$MenuMusic.stop()
	
	global.initialize()
	
	var overworld = overworld_scene.instantiate()
	get_parent().add_child(overworld)
	self.queue_free()


func _on_start_pressed():
	start_game()
#	$MenuMusic.stop()
#
#	global.initialize()
#
#	var overworld = overworld_scene.instantiate()
#	get_parent().add_child(overworld)
#	self.queue_free()


func _on_back_pressed():
	$Control/BeginButton.grab_focus()
	$Control/GridSizeRect.visible = false


func _on_done_button_pressed():
	$Control/SettingsRect.visible = false
	$Control/BeginButton.grab_focus()


func _on_settings_button_pressed():
	$Control/SettingsRect.visible = true
	$Control/SettingsRect/MusicSlider.grab_focus()

# settings signals
func _on_invert_check_toggled(button_pressed):
	global.invert = button_pressed


func _on_quit_button_pressed():
	get_tree().quit()


func _on_quality_check_toggled(button_pressed):
	global.quality = !button_pressed


func _on_music_slider_value_changed(value):
	print(linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value))


func _on_fx_slider_value_changed(value):
	print(linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("fx"), linear_to_db(value))


# button animations
func _on_begin_button_focus_entered():
	$Control/AnimationPlayer.play("begin")

func _on_help_button_focus_entered():
	$Control/AnimationPlayer.play("help")

func _on_settings_button_focus_entered():
	$Control/AnimationPlayer.play("settings")

func _on_leaderboards_button_focus_entered():
	$Control/AnimationPlayer.play("leaderboards")

func _on_quit_button_focus_entered():
	$Control/AnimationPlayer.play("quit")

func _on_begin_button_focus_exited():
	$Control/BeginButton.scale = Vector2(1, 1)

func _on_help_button_focus_exited():
	$Control/HelpButton.scale = Vector2(1, 1)

func _on_settings_button_focus_exited():
	$Control/SettingsButton.scale = Vector2(1, 1)

func _on_leaderboards_button_focus_exited():
	$Control/LeaderboardsButton.scale = Vector2(1, 1)

func _on_quit_button_focus_exited():
	$Control/QuitButton.scale = Vector2(1, 1)
	
# mouse
func _on_help_button_mouse_entered():
	$Control/AnimationPlayer.play("help")


# help screen
func _on_help_button_pressed():
	$Control/HelpRect.visible = true
	$Control/HelpRect/Controls.visible = true
	$Control/HelpRect/HelpNextButton.grab_focus()


func _on_help_done_button_pressed():
	$Control/HelpRect.visible = false
	helpIndex = 0
	helpLabels[0].visible = true
	$Control/BeginButton.grab_focus()


func _on_help_back_button_pressed():
	helpLabels[helpIndex].visible = false
	helpIndex -= 1
	if helpIndex < 0:
		helpIndex = helpLabels.size() - 1
	helpLabels[helpIndex].visible = true


func _on_help_next_button_pressed():
	helpLabels[helpIndex].visible = false
	helpIndex += 1
	if helpIndex > helpLabels.size() - 1:
		helpIndex = 0
	helpLabels[helpIndex].visible = true


func _on_animation_player_animation_finished(anim_name):
	print('done zooming')
	$Title/AnimationPlayer.play('wiggle')


func _on_horizontal_look_slider_value_changed(value):
	global.horizontal_cam_speed = value


func _on_maze_mode_checkbox_toggled(button_pressed):
	global.maze_mode = button_pressed


func _on_seed_text_edit_text_changed(new_text):
	global.seed = new_text


func _on_mouse_look_slider_value_changed(value):
	global.mouse_camera_sensitiviy = 0.01 + (0.001 * value)


func _on_grid_size_slider_value_changed(value):
	if value == 1:
		$Control/GridSizeRect/GridSizeLabel.text = "Grid size: 3x3"
		global.room_rows = 3
		global.room_cols = 3
		global.grid_size = 1
		
	if value == 2:
		$Control/GridSizeRect/GridSizeLabel.text = "Grid size: 5x5"
		global.room_rows = 5
		global.room_cols = 5
		global.grid_size = 2
		
	if value == 3:
		$Control/GridSizeRect/GridSizeLabel.text = "Grid size: 10x10"
		global.room_rows = 10
		global.room_cols = 10
		global.grid_size = 3


func _on_leaderboard_done_button_pressed():
	$Control/LeaderboardsRect.close()
	$Control/BeginButton.grab_focus()


func _on_leaderboards_button_pressed():
	$Control/LeaderboardsRect.open()
	$Control/LeaderboardsRect/SizeSlider.grab_focus()

