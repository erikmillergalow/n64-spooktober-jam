extends Node

var menu_world_scene = preload('res://world/world.tscn')
var win_scene = preload('res://win_room/win_room.tscn')

@onready var global = get_node('/root/global')

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	var menu_world = menu_world_scene.instantiate()
	print($N64Layer/HBlur/SubViewport/DitherBand/SubViewport.get_children())
	$N64Layer/HBlur/SubViewport/DitherBand/SubViewport.add_child(menu_world)

	if global.win:
		$N64Layer/HBlur/SubViewport/DitherBand/SubViewport/WinRoom.queue_free()
	else:
		$N64Layer/HBlur/SubViewport/DitherBand/SubViewport/Overworld.queue_free()

