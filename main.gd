extends Node

var menu_world_scene = preload('res://world/world.tscn')
var win_scene = preload('res://win_room/win_room.tscn')

@onready var global = get_node('/root/global')

func _ready():
	pass
#	SilentWolf.Auth.auto_login_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if global.quality != $N64Layer/HBlur.material.get_shader_parameter("enabled"):
		$N64Layer/HBlur/SubViewport/DitherBand.material.set_shader_parameter("enabled", global.quality)
		$N64Layer/HBlur.material.set_shader_parameter("enabled", global.quality)
	
	if global.win and not global.done:
		global.done = true
		var win_room = win_scene.instantiate()
		print($N64Layer/HBlur/SubViewport/DitherBand/SubViewport.get_children())
		$N64Layer/HBlur/SubViewport/DitherBand/SubViewport.add_child(win_room)
		$N64Layer/HBlur/SubViewport/DitherBand/SubViewport/Overworld.queue_free()


func _on_end_run_pressed():
	$N64Layer/Control/AreYouSure.visible = true
	$N64Layer/Control/AreYouSure/No.grab_focus()


func _on_yes_pressed():
	var menu_world = menu_world_scene.instantiate()
	print($N64Layer/HBlur/SubViewport/DitherBand/SubViewport.get_children())
	$N64Layer/HBlur/SubViewport/DitherBand/SubViewport.add_child(menu_world)

	if global.win:
		$N64Layer/HBlur/SubViewport/DitherBand/SubViewport/WinRoom.queue_free()
	else:
		$N64Layer/HBlur/SubViewport/DitherBand/SubViewport/Overworld.queue_free()


func _on_no_pressed():
	$N64Layer/Control/AreYouSure.visible = false
	$N64Layer/Control/EndRun.grab_focus()
