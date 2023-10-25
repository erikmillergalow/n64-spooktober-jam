extends Node3D


var room_rows = 3
var room_cols = 3

@onready var room_scene = load("res://room/room.tscn")
@onready var ghost_scene = load('res://ghost/ghost-blend.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
	create_grid()

func spawn_ghosts(amount):
	for i in range(0, amount):
		var ghost = ghost_scene.instantiate()
		ghost.global_transform.origin = global_transform.origin + Vector3(randi()%80 + 10, 0, randi()%80 + 10)
		owner.add_child.call_deferred(ghost)

func create_grid():
	for row in range(0, room_rows):
		for col in range(0, room_cols):
			var room = room_scene.instantiate()
			room.global_transform.origin = global_transform.origin
			owner.add_child.call_deferred(room)
			spawn_ghosts(3)
			global_transform.origin += Vector3(-100, 0, 0)
		global_transform.origin += Vector3(100 * room_cols, 0, 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
