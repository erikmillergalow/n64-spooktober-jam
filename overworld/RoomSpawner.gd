extends Node3D


var room_rows = 3
var room_cols = 3

@onready var room_scene = load("res://room/room.tscn")
@onready var boss_room_scene = load("res://boss_room/boss_room.tscn")

# enemies
@onready var ghost_scene = load('res://ghost/ghost-blend.tscn')
@onready var spiky_scene = load('res://spiky/spiky.tscn')

# objects
@onready var tree_scene = load('res://objects/tree/tree.tscn')
@onready var key_chest_scene = load('res://key_chest/key_chest.tscn')

var key_chest_spawned = false
var boss_room_spawned = false

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	create_grid()


#func set_player(body):
#	player = body

func spawn_room(is_last):
	var room = room_scene.instantiate()
	room.global_transform.origin = global_transform.origin
	owner.add_child.call_deferred(room)

	if not key_chest_spawned:
		if randf() < 0.1 or is_last:
			spawn_chest()


func spawn_chest():
	var key_chest = key_chest_scene.instantiate()
	var placement
	var corner_prob = randf()
	if corner_prob < 0.25:
		placement = Vector3(randi()%8 + 2, 0, randi()%8 + 2)
	elif corner_prob < 0.5:
		placement = Vector3(randi()%8 + 2, 0, randi()%8 + 2)
	elif corner_prob < 0.75:
		placement = Vector3(randi()%8 + 2, 0, randi()%8 + 2)
	else:
		placement = Vector3(randi()%8 + 2, 0, randi()%8 + 2)
		
	key_chest.global_transform.origin = global_transform.origin + placement
	owner.add_child.call_deferred(key_chest)
	key_chest_spawned = true
	print('key_chest spawned')
	print(key_chest.global_transform.origin)

func spawn_ghosts(amount):
	for i in range(0, amount):
		var ghost = ghost_scene.instantiate()
		var placement = Vector3(randi()%80 + 10, 0, randi()%80 + 10)
		ghost.global_transform.origin = global_transform.origin + placement
		owner.add_child.call_deferred(ghost)


func spawn_spiky(amount):
	for i in range(0, amount):
		var spiky = spiky_scene.instantiate()
		var placement = Vector3(randi()%80 + 10, 0, randi()%80 + 10)
		spiky.global_transform.origin = global_transform.origin + placement
		owner.add_child.call_deferred(spiky)


func spawn_trees(amount):
	for i in range(0, amount):
		var tree = tree_scene.instantiate()
		var placement =  Vector3(randi()%80 + 10, 0, randi()%80 + 10)
		tree.global_transform.origin = global_transform.origin + placement
		tree.scale = Vector3(1, 1, 1) * ((randf() * 2) + 1)
		owner.add_child.call_deferred(tree)

func spawn_boss_room():
	var boss_room = boss_room_scene.instantiate()
	boss_room.global_transform.origin = global_transform.origin
	boss_room_spawned = true
	owner.add_child.call_deferred(boss_room)


func create_grid():
	var is_last = false
	for row in range(0, room_rows):
		for col in range(0, room_cols):
			if row == room_rows - 1 and col == room_cols - 1:
				print('is_last')
				is_last = true
			spawn_room(is_last)
			
			if row == 0:
				spawn_spiky(randi() % 2)
				spawn_ghosts(randi() % 5 + 2)
				spawn_trees(randi() % 8)
			if row == 1:
				spawn_spiky(randi() % 10 + 1)
				spawn_ghosts(randi() % 10 + 4)
				spawn_trees(randi() % 8)
			if row == 2:
				spawn_spiky(randi() % 2 + 15)
				spawn_ghosts(randi() % 15 + 20)
				spawn_trees(randi() % 4)
			
			global_transform.origin += Vector3(-100, 0, 0)
		global_transform.origin += Vector3(100 * room_cols, 0, 100)
	
	for row in range(0, room_rows):
		if !boss_room_spawned:
			if randf() < 0.33 or (row == room_rows - 1):
				spawn_boss_room()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
