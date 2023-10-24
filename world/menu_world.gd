extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	$Floor.set_instance_shader_parameter('uv_offset', 0.0004)
	$Floor.mesh.material.uv1_offset.z -= 0.03
	
	if Input.is_action_pressed('start'):
		print('pressed')
		get_tree().change_scene_to_file("res://overworld/overworld.tscn")


func _on_begin_button_pressed():
	print('pressed')
	get_tree().change_scene_to_file("res://overworld/overworld.tscn")
