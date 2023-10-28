extends Node3D

var overworld_scene = preload('res://overworld/overworld.tscn')

@onready var global = get_node("/root/global")

var helpIndex = 0
@onready var helpLabels = [
	$Control/HelpRect/Controls,
	$Control/HelpRect/Upgrades,
	$Control/HelpRect/Monsters,
	$Control/HelpRect/Premise,
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/BeginButton.grab_focus()
	randomize()
	pass # Replace with function body.


func _process(delta):
	$Floor.mesh.material.uv1_offset.z -= 0.03
	$WorldEnvironment.environment.sky_rotation.y -= 0.002


func _on_begin_button_pressed():
	$MenuMusic.stop()
	
	global.initialize()
	
	var overworld = overworld_scene.instantiate()
	get_parent().add_child(overworld)
	self.queue_free()


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
	global.quality = button_pressed


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


func _on_quit_button_focus_entered():
	$Control/AnimationPlayer.play("quit")

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
