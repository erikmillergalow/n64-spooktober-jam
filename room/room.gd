extends Node3D

@onready var ghost_scene = load('res://ghost/ghost-blend.tscn')

@onready var spawn_zone = $Area3D/SpawnZone.shape.extents
@onready var spawn_origin = $Area3D/SpawnZone.global_position

var num_ghosts = 1

func _ready():
	pass
#	for i in range(0, num_ghosts):
#		var ghost = ghost_scene.instantiate()
#		var spawn_point = transform.origin #+ Vector3(randi() % 10, 0, randi() % 10)
#		ghost.transform.origin = transform.origin
#		print(transform.origin)
##		ghost.global_transform.origin = global_transform.origin / 6 + Vector3(50, 0, 0)
##		ghost.global_transform.origin = get_spawn_location()
#		add_child.call_deferred(ghost)

func get_spawn_location():
	var x = randf_range(spawn_origin.x, spawn_zone.x)
	var z = randf_range(spawn_origin.x, spawn_zone.z)
	
	return Vector3(x, 0, z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
