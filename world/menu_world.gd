extends Node3D

var overworld_scene = preload('res://overworld/overworld.tscn')

@onready var global = get_node("/root/global")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/BeginButton.grab_focus()
	randomize()
	pass # Replace with function body.


func _process(delta):
	$Floor.mesh.material.uv1_offset.z -= 0.03
	$WorldEnvironment.environment.sky_rotation.y -= 0.002


func _on_begin_button_pressed():
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
