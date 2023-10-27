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
	
#	if Input.is_action_just_pressed('jump'):
#		get_tree().get_focus_owner().pressed = true
#	if Input.is_action_pressed('start'):
#		print('pressed')
#		var overworld = overworld_scene.instantiate()
#		print(get_parent())
#		get_parent().add_child(overworld)
#		self.queue_free()


func _on_begin_button_pressed():
	print('pressed')
	global.win = false
	var overworld = overworld_scene.instantiate()
	get_parent().add_child(overworld)
	self.queue_free()


func _on_begin_button_focus_entered():
	$Control/AnimationPlayer.play("begin")


func _on_help_button_focus_entered():
	$Control/AnimationPlayer.play("help")


func _on_settings_button_focus_entered():
	$Control/AnimationPlayer.play("settings")


func _on_quit_button_focus_entered():
	$Control/AnimationPlayer.play("quit")


func _on_quit_button_pressed():
	get_tree().quit()
