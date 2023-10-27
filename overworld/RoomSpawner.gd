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
@onready var house_scene = load('res://objects/house/house.tscn')
@onready var tower_scene = load('res://objects/tower.tscn')
@onready var crate_scene = load('res://objects/crate/crate.tscn')

var key_chest_spawned = false
var boss_room_spawned = false

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	create_grid()


func spawn_room(is_last, closed_gates):
	var room = room_scene.instantiate()
	room.global_transform.origin = global_transform.origin
	
	for gate in closed_gates:
		print(gate)
		room.close_laser_gate(gate)
	
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


func spawn_monsters(scene, amount, intensity):
	for i in range(0, amount):
		var monster = scene.instantiate()
		var placement = Vector3(randi()%80 + 10, 0, randi()%80 + 10)
		monster.global_transform.origin = global_transform.origin + placement
		owner.add_child.call_deferred(monster)


func spawn_objects(scene, amount):
	for i in range(0, amount):
		var object = scene.instantiate()
		var placement =  Vector3(randi() % 80 + 10, 0, randi() % 80 + 10)
		object.global_transform.origin = global_transform.origin + placement
		object.scale = Vector3(1, (randf() * 1) + 1, 1) * ((randf() * 2) + 1)
		object.rotation_degrees.y = randf() * 360.0
		owner.add_child.call_deferred(object)


func spawn_boss_room(placement, rotation):
	var boss_room = boss_room_scene.instantiate()
	boss_room.global_transform.origin = global_transform.origin + placement
	boss_room.rotation_degrees.y = rotation
	boss_room_spawned = true
	owner.add_child.call_deferred(boss_room)


func create_grid():
	var is_last = false
	var boss_room_chance = 0.0
	for row in range(0, room_rows):
		for col in range(0, room_cols):
			if row == room_rows - 1 and col == room_cols - 1:
				print('is_last')
				is_last = true
			
			if !boss_room_spawned:
				boss_room_chance = randf()

#				if randf() < 0.33 or (row == room_rows - 1):
#					spawn_boss_room()
			
			# try to add boss rooms at edges to figure out where to leave open for the boss
			if row == 0:
				if col == 0:
					# first corner on the left
					if boss_room_chance > 0.9 and not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['south'])
							spawn_boss_room(Vector3(150.0, 0.0, 50.0), 90.0)
						else:
							spawn_room(is_last, ['west'])
							spawn_boss_room(Vector3(50.0, 0.0, -50.0), 180.0)
					else:
						spawn_room(is_last, ['south', 'west'])
				
				elif col == room_cols - 1:
					# first corner on the right
					if boss_room_chance > 0.8 and not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['east'])
							spawn_boss_room(Vector3(50.0, 0.0, -50.0), 180.0)
						else:
							spawn_room(is_last, ['south'])
							spawn_boss_room(Vector3(-50.0, 0.0, 50.0), 270.0)
					else:
						spawn_room(is_last, ['south', 'east'])
				else:
					spawn_room(is_last, [])

			elif row != room_rows - 1:
				if col == 0:
#					# west end
					if boss_room_chance > 0.7 and not boss_room_spawned:
						spawn_room(is_last, [])
						spawn_boss_room(Vector3(150.0, 0.0, 50.0), 90.0)
					else:
						spawn_room(is_last, ['west'])
				elif col == room_cols - 1:
#					# east end
					if boss_room_chance > 0.7 and not boss_room_spawned:
						spawn_room(is_last, [])
						spawn_boss_room(Vector3(-50.0, 0.0, 50.0), 270.0)
					else:
						spawn_room(is_last, ['east'])
				else:
					spawn_room(is_last, [])
			elif row == room_rows - 1:
				if col == 0:
					# far corner on the left
					if boss_room_chance > 0.4 and not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['north'])
							spawn_boss_room(Vector3(150.0, 0.0, 50.0), 90.0)
						else:
							spawn_room(is_last, ['west'])
							spawn_boss_room(Vector3(50.0, 0.0, 150.0), 0.0)
					else:
						spawn_room(is_last, ['north', 'west'])
				elif col == room_cols - 1:
					# far corner on the right
					if not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['north'])
							spawn_boss_room(Vector3(-50.0, 0.0, 50.0), 270.0)
						else:
							spawn_room(is_last, ['east'])
							spawn_boss_room(Vector3(50.0, 0.0, 150.0), 0.0)
					else:
						spawn_room(is_last, ['north', 'east'])
				else:
#					# middle end
					if boss_room_chance > 0.80 and not boss_room_spawned:
						spawn_room(is_last, [])
						spawn_boss_room(Vector3(50.0, 0.0, 150.0), 0.0)
					spawn_room(is_last, ['north'])
			
			if row == 0:
				spawn_monsters(ghost_scene, randi() % 5 + 2, 0)
				spawn_monsters(spiky_scene, randi() % 2, 0)
				spawn_objects(tree_scene, randi() % 8)
				spawn_objects(house_scene, randi() % 5)
				spawn_objects(crate_scene, randi() % 9)
			if row == 1:
				spawn_monsters(ghost_scene, randi() % 10 + 6, 1)
				spawn_monsters(spiky_scene, randi() % 6 + 3, 1)
				spawn_objects(tree_scene, randi() % 8 + 4)
				spawn_objects(house_scene, randi() % 4 + 3)
			if row == 2:
				spawn_monsters(ghost_scene, randi() % 15 + 15, 2)
				spawn_monsters(spiky_scene, randi() % 3 + 15, 2)
				spawn_objects(tree_scene, randi() % 4 + 4)
				spawn_objects(tower_scene, randi() % 4 + 4)
				spawn_objects(tower_scene, randi() % 2 + 1)
			
			global_transform.origin += Vector3(-100, 0, 0)
		global_transform.origin += Vector3(100 * room_cols, 0, 100)
	
#	for row in range(0, room_rows):
#		if !boss_room_spawned:
#			if randf() < 0.33 or (row == room_rows - 1):
#				spawn_boss_room()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
