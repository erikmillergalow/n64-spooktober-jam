extends Node3D

@onready var ghost_scene = load('res://ghost/ghost-blend.tscn')

@onready var spawn_zone = $Area3D/SpawnZone.shape.extents
@onready var spawn_origin = $Area3D/SpawnZone.global_position

var num_ghosts = 1

func _ready():
	pass

func get_spawn_location():
	var x = randf_range(spawn_origin.x, spawn_zone.x)
	var z = randf_range(spawn_origin.x, spawn_zone.z)
	
	return Vector3(x, 0, z)


func spawn_at_location(location):
	global_transform.origin = location


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func close_laser_gate(side):
	if side == 'north':
		$RoomWallNorth.close_laser_gate()
	if side == 'south':
		$RoomWallSouth.close_laser_gate()
	if side == 'east':
		$RoomWallEast.close_laser_gate()
	if side == 'west':
		$RoomWallWest.close_laser_gate()
