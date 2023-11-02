extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	$TileMap.add_layer(0)
	$TileMap.set_layer_enabled(0, true)
	$TileMap.set_layer_name(0, "world")
	$TileMap.set_layer_z_index(0, 0)
	
	
	$TileMap.add_layer(2)
	$TileMap.set_layer_enabled(2, true)
	$TileMap.set_layer_name(2, "tops")
	$TileMap.set_layer_z_index(2, 1)
	
	$TileMap.add_layer(1)
	$TileMap.set_layer_enabled(1, true)
	$TileMap.set_layer_name(1, "rights")
	$TileMap.set_layer_z_index(1, 1)
	
	
#	$TileMap.add_layer(2)
#	$TileMap.set_layer_enabled(2, true)
#	$TileMap.set_layer_name(2, "fog")
#	$TileMap.set_layer_z_index(2, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func draw_room(tuple, placement):
	print("drawing room")
	
	var x = floor((placement.x + 50) / 100)
	var y = floor((placement.z + 50) / 100)
	
	print(x)
	print(y)
	
	# place open ground
	$TileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
	
	if tuple.top:
		$TileMap.set_cell(1, Vector2i(x, y), 0, Vector2i(2, 0))
	if tuple.right:
		$TileMap.set_cell(1, Vector2i(x, y), 0, Vector2i(3, 0))
	if tuple.bottom:
		$TileMap.set_cell(1, Vector2i(x, y), 0, Vector2i(4, 0))
	if tuple.left:
		$TileMap.set_cell(1, Vector2i(x, y), 0, Vector2i(5, 0))
	
	# place fog overlay
#	$TileMap.set_cell(1, Vector2(x, y), 2, Vector2(0, 0))
