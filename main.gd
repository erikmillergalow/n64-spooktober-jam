extends Node

var menu_world_scene = preload('res://world/world.tscn')
var win_scene = preload('res://win_room/win_room.tscn')

@onready var global = get_node('/root/global')

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	$N64Layer/HBlur/SubViewport/DitherBand/SubViewport/Overworld.queue_free()

