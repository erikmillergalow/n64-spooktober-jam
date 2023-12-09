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
@onready var tower_scene = load('res://objects/tower/tower.tscn')
@onready var crate_scene = load('res://objects/crate/crate.tscn')

#@onready var map = get_node("../Player/Control/Map")

var key_chest_spawned = false
var boss_room_spawned = false

var player

var visited = []
var maze = []

var total_monsters = 0

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = global.seed.hash()
	if global.maze_mode:
		create_maze()
	else:
		create_grid()


func spawn_room(is_last, closed_gates, row):
	var room = room_scene.instantiate()
	room.transform.origin = global_transform.origin
	
	for gate in closed_gates:
		print(gate)
		room.close_laser_gate(gate)
	
	owner.add_child.call_deferred(room)
	
	if not key_chest_spawned and is_last:
		spawn_chest(row)
	elif not key_chest_spawned:
		if rng.randf() < 0.2:
			spawn_chest(row)


func spawn_chest(row):
	if (row == global.room_rows - 1):
		var key_chest = key_chest_scene.instantiate()
		var placement
		var corner_prob = rng.randf()
		if corner_prob < 0.25:
			placement = Vector3(rng.randi()%8 + 2, 0, rng.randi()%8 + 2)
		elif corner_prob < 0.5:
			placement = Vector3(rng.randi()%8 + 2, 0, rng.randi()%8 + 2)
		elif corner_prob < 0.75:
			placement = Vector3(rng.randi()%8 + 2, 0, rng.randi()%8 + 2)
		else:
			placement = Vector3(rng.randi()%8 + 2, 0, rng.randi()%8 + 2)
			
		key_chest.transform.origin = global_transform.origin + placement
		owner.add_child.call_deferred(key_chest)
		key_chest_spawned = true
		print('key_chest spawned')
		print(key_chest.transform.origin)


func spawn_monsters(scene, amount, intensity):
	total_monsters += amount
	for i in range(0, amount):
		var monster = scene.instantiate()
		var placement = Vector3(rng.randi()%80 + 10, 0, rng.randi()%80 + 10)
		monster.transform.origin = global_transform.origin + placement
		monster.set_intensity(intensity)
		
		owner.add_child.call_deferred(monster)


func spawn_objects(scene, amount):
	for i in range(0, amount):
		var object = scene.instantiate()
		var placement =  Vector3(rng.randi() % 80 + 10, 0, rng.randi() % 80 + 10)
		object.transform.origin = global_transform.origin + placement
		
		if scene != crate_scene:
			object.scale = Vector3(1, (rng.randf() * 1) + 1, 1) * ((rng.randf() * 2) + 1)
		object.rotation_degrees.y = rng.randf() * 360.0
		owner.add_child.call_deferred(object)


func spawn_boss_room(placement, room_rotation):
	print('spawn boss room')
	var boss_room = boss_room_scene.instantiate()
	boss_room.transform.origin = global_transform.origin + placement
	boss_room.rotation_degrees.y = room_rotation
	boss_room_spawned = true
	owner.add_child.call_deferred(boss_room)


func generate_maze():
	# initialize
	maze.clear()
	visited.clear()
	for y in range(global.room_cols):
		maze.append([])
		visited.append([])
		for x in range(global.room_rows):
			maze[y].append({"top": true, "right": true, "bottom": true, "left": true})
			visited[y].append(false)
	
	# start at random cell
	var stack = []
	var start_x = rng.randi() % int(global.room_rows)
	var start_y = rng.randi() % int(global.room_cols)
	
	dfs(start_x, start_y, stack)

func dfs(x, y, stack):
	# keep track of all that have been visited so far
	visited[y][x] = true
	stack.push_back(Vector2(x, y))
	
	# start pushing/popping to remove all necessary walls
	while stack.size() > 0:
		var current = stack[stack.size() - 1]
		var neighbors = get_unvisited_neighbors(current.x, current.y)
		if neighbors.size() > 0:
			var nextIndex = rng.randi() % neighbors.size()
			var next = neighbors[nextIndex]
			remove_wall(current.x, current.y, next.x, next.y)
			visited[next.y][next.x] = true
			stack.push_back(next)
			neighbors.pop_at(nextIndex)
		else:
			stack.pop_back()

func get_unvisited_neighbors(x, y):
	var neighbors = []
	var directions = [
		Vector2(-1, 0),  # left
		Vector2(0, -1),  # up
		Vector2(1, 0),   # right
		Vector2(0, 1)    # down
	]
	
	# check all directions for unvisited rooms
	for direction in directions:
		var nx = x + int(direction.x)
		var ny = y + int(direction.y)
		if 0 <= nx and nx < global.room_rows and 0 <= ny and ny < global.room_cols and not visited[ny][nx]:
			neighbors.append(Vector2(nx, ny))
			
	return neighbors

func remove_wall(x1, y1, x2, y2):
	if x2 == x1 + 1:  # neighbor to the right
		maze[y1][x1]["right"] = false
		maze[y2][x2]["left"] = false
	elif x2 == x1 - 1:  # neighbor to the left
		maze[y1][x1]["left"] = false
		maze[y2][x2]["right"] = false
	elif y2 == y1 + 1:  # neighbor below
		maze[y1][x1]["bottom"] = false
		maze[y2][x2]["top"] = false
	elif y2 == y1 - 1:  # neighbor above
		maze[y1][x1]["top"] = false
		maze[y2][x2]["bottom"] = false


func create_maze():
	generate_maze()
	
	room_rows = global.room_rows
	room_cols = global.room_cols
	
	var boss_room_chance = 0.0
	boss_room_spawned = false
	var is_last = false
	for y in range(room_cols - 1, -1, -1):
#		print(" ")
#		print(maze[y])
		for x in range(0, room_rows):
			print('x')
			print(x)
			print('y')
			print(y)
			
			if y == 0 and x == room_rows - 1:
				print('is last!')
				is_last = true
			
			# open the entrance
			if x == 1 and y == room_cols - 1:
				maze[y][x]['bottom'] = false
			
			if !boss_room_spawned:
				boss_room_chance = rng.randf()
			
			if y == room_cols - 1:
				if x != 1 and ((boss_room_chance > 0.9 and not boss_room_spawned) or (is_last and not boss_room_spawned)):
					var placement = Vector3(50.0, 0.0, -50.0)
#					spawn_boss_room(placement, 180.0)
#					maze[y][x]['bottom'] = false
					spawn_room_from_tuple(maze[y][x], is_last, x)
					spawn_boss_room(placement, 180.0)
					
				else:
					spawn_room_from_tuple(maze[y][x], is_last, x)
					
				if x == 1:
					spawn_monsters(ghost_scene, rng.randi() % 5 + 3, 0)
				else:
					spawn_monsters(ghost_scene, rng.randi() % 5 + 5, 0)
					spawn_monsters(spiky_scene, rng.randi() % 2, 0)
				spawn_objects(tree_scene, rng.randi() % 8)
				spawn_objects(house_scene, rng.randi() % 5)
				spawn_objects(crate_scene, rng.randi() % 9)
				
			elif y == 0:
				if (boss_room_chance > 0.6 and not boss_room_spawned) or (is_last and not boss_room_spawned):
					var placement = Vector3(50.0 , 0.0, 150)
#					spawn_boss_room(placement, 0.0)
#					maze[y][x]['top'] = false
					spawn_room_from_tuple(maze[y][x], is_last, x)
					spawn_boss_room(placement, 0.0)					
				else:
					spawn_room_from_tuple(maze[y][x], is_last, x)
					
				spawn_monsters(ghost_scene, rng.randi() % 15 + 15, (rng.randi() % 2) + 2)
				spawn_monsters(spiky_scene, rng.randi() % 3 + 15, (rng.randi() % 2) + 2)
				spawn_objects(tree_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 2 + 1)
				
			elif x == 0:
				if (boss_room_chance > 0.6 and not boss_room_spawned) or (is_last and not boss_room_spawned):
					var placement = Vector3(150.0, 0.0, 50.0)
#					spawn_boss_room(placement, 90.0)
#					maze[y][x]['left'] = false
					spawn_room_from_tuple(maze[y][x], is_last, x)
					spawn_boss_room(placement, 90.0)
				else:
					spawn_room_from_tuple(maze[y][x], is_last, x)
					
				spawn_monsters(ghost_scene, rng.randi() % 15 + 15, (rng.randi() % 2) + 2)
				spawn_monsters(spiky_scene, rng.randi() % 3 + 15, (rng.randi() % 2) + 2)
				spawn_objects(tree_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 2 + 1)
				
			elif x == room_rows - 1:
				if (boss_room_chance > 0.8 and not boss_room_spawned) or (is_last and not boss_room_spawned):
					var placement = Vector3(-50.0, 0.0, 50.0)
#					maze[y][x]['right'] = false
#					spawn_boss_room(placement, 270.0)
					spawn_room_from_tuple(maze[y][x], is_last, x)
					spawn_boss_room(placement, 270.0)
				else:
					spawn_room_from_tuple(maze[y][x], is_last, x)
					
				spawn_monsters(ghost_scene, rng.randi() % 10 + 6, 1)
				spawn_monsters(spiky_scene, rng.randi() % 6 + 3, (rng.randi() % 2) + 2)
				spawn_objects(tree_scene, rng.randi() % 8 + 4)
				spawn_objects(house_scene, rng.randi() % 4 + 3)
				
			else:
				spawn_room_from_tuple(maze[y][x], is_last, x)
				
				var middle_chance = randf()
				if middle_chance < 0.70:
					spawn_monsters(ghost_scene, rng.randi() % 10 + 6, 1)
					spawn_monsters(spiky_scene, rng.randi() % 6 + 3, (rng.randi() % 2) + 2)
					spawn_objects(tree_scene, rng.randi() % 4 + 4)
					spawn_objects(house_scene, rng.randi() % 5 + 3)
					spawn_objects(crate_scene, rng.randi() % 6)
				elif middle_chance < 0.85:
					spawn_monsters(ghost_scene, rng.randi() % 5 + 5, 0)
					spawn_monsters(spiky_scene, rng.randi() % 2, 0)
					spawn_objects(tree_scene, rng.randi() % 8)
					spawn_objects(house_scene, rng.randi() % 5)
					spawn_objects(crate_scene, rng.randi() % 9)
				elif middle_chance < 0.95:
					spawn_monsters(ghost_scene, rng.randi() % 15 + 15, (rng.randi() % 2) + 2)
					spawn_monsters(spiky_scene, rng.randi() % 3 + 15, (rng.randi() % 2) + 2)
					spawn_objects(tree_scene, rng.randi() % 4 + 4)
					spawn_objects(tower_scene, rng.randi() % 4 + 4)
				else:
					spawn_monsters(spiky_scene, rng.randi() % 3 + 20, (rng.randi() % 2) + 2)
					spawn_objects(tower_scene, rng.randi() % 4 + 8)
					spawn_objects(crate_scene, rng.randi() % 9)
			
			global_transform.origin += Vector3(-100, 0, 0)
		global_transform.origin += Vector3(100 * room_cols, 0, 100)

func spawn_room_from_tuple(tuple, is_last, row):
	var room = room_scene.instantiate()
	room.transform.origin = global_transform.origin
	
	if tuple.top:
		room.close_laser_gate('north')
	if tuple.right:
		room.close_laser_gate('east')
	if tuple.bottom:
		room.close_laser_gate('south')
	if tuple.left:
		room.close_laser_gate('west')
	
	owner.add_child.call_deferred(room)
	
	if not key_chest_spawned and is_last:
		spawn_chest(row)
	elif not key_chest_spawned:
		if rng.randf() < 0.2:
			spawn_chest(row)


func create_grid():
	var is_last = false
	var boss_room_chance = 0.0
	room_rows = global.room_rows
	room_cols = global.room_cols
	for row in range(0, room_rows):
		for col in range(0, room_cols):
			if row == room_rows - 1 and col == room_cols - 1:
				is_last = true
			
			if !boss_room_spawned:
				boss_room_chance = rng.randf()
			
			# try to add boss rooms at edges to figure out where to leave open for the boss
			if row == 0:
				if col == 0:
					# first corner on the left
					if boss_room_chance > 0.9 and not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['south'], row)
							spawn_boss_room(Vector3(150.0, 0.0, 50.0), 90.0)
						else:
							spawn_room(is_last, ['west'], row)
							spawn_boss_room(Vector3(50.0, 0.0, -50.0), 180.0)
					else:
						spawn_room(is_last, ['south', 'west'], row)
				
				elif col == room_cols - 1:
					# first corner on the right
					if boss_room_chance > 0.8 and not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['east'], row)
							spawn_boss_room(Vector3(50.0, 0.0, -50.0), 180.0)
						else:
							spawn_room(is_last, ['south'], row)
							spawn_boss_room(Vector3(-50.0, 0.0, 50.0), 270.0)
					else:
						spawn_room(is_last, ['south', 'east'], row)
				else:
					spawn_room(is_last, [], row)

			elif row != room_rows - 1:
				if col == 0:
#					# west end
					if boss_room_chance > 0.7 and not boss_room_spawned:
						spawn_room(is_last, [], row)
						spawn_boss_room(Vector3(150.0, 0.0, 50.0), 90.0)
					else:
						spawn_room(is_last, ['west'], row)
				elif col == room_cols - 1:
#					# east end
					if boss_room_chance > 0.7 and not boss_room_spawned:
						spawn_room(is_last, [], row)
						spawn_boss_room(Vector3(-50.0, 0.0, 50.0), 270.0)
					else:
						spawn_room(is_last, ['east'], row)
				else:
					spawn_room(is_last, [], row)
			elif row == room_rows - 1:
				if col == 0:
					# far corner on the left
					if boss_room_chance > 0.4 and not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['north'], row)
							spawn_boss_room(Vector3(150.0, 0.0, 50.0), 90.0)
						else:
							spawn_room(is_last, ['west'], row)
							spawn_boss_room(Vector3(50.0, 0.0, 150.0), 0.0)
					else:
						spawn_room(is_last, ['north', 'west'], row)
				elif col == room_cols - 1:
					# far corner on the right
					if not boss_room_spawned:
						if boss_room_chance < 0.5:
							spawn_room(is_last, ['north'], row)
							spawn_boss_room(Vector3(-50.0, 0.0, 50.0), 270.0)
						else:
							spawn_room(is_last, ['east'], row)
							spawn_boss_room(Vector3(50.0, 0.0, 150.0), 0.0)
					else:
						spawn_room(is_last, ['north', 'east'], row)
				else:
#					# middle end
					if boss_room_chance > 0.80 and not boss_room_spawned:
						spawn_room(is_last, [], row)
						spawn_boss_room(Vector3(50.0, 0.0, 150.0), 0.0)
					else:
						spawn_room(is_last, [], row)
			
			if row == 0:
				if col == 1:
					spawn_monsters(ghost_scene, rng.randi() % 5 + 3, 0)
				else:
					spawn_monsters(ghost_scene, rng.randi() % 5 + 5, 0)
					spawn_monsters(spiky_scene, rng.randi() % 2, 0)
				spawn_objects(tree_scene, rng.randi() % 8)
				spawn_objects(house_scene, rng.randi() % 5)
				spawn_objects(crate_scene, rng.randi() % 9)
			if row == 1:
				spawn_monsters(ghost_scene, rng.randi() % 10 + 6, 1)
				spawn_monsters(spiky_scene, rng.randi() % 6 + 3, (rng.randi() % 2) + 2)
				spawn_objects(tree_scene, rng.randi() % 8 + 4)
				spawn_objects(house_scene, rng.randi() % 4 + 3)
			if row == 2:
				spawn_monsters(ghost_scene, rng.randi() % 15 + 15, (rng.randi() % 2) + 2)
				spawn_monsters(spiky_scene, rng.randi() % 3 + 15, (rng.randi() % 2) + 2)
				spawn_objects(tree_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 2 + 1)
			if row > 2:
				spawn_monsters(ghost_scene, rng.randi() % 15 + 15, (rng.randi() % 2) + 2)
				spawn_monsters(spiky_scene, rng.randi() % 3 + 15, (rng.randi() % 2) + 2)
				spawn_objects(tree_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 4 + 4)
				spawn_objects(tower_scene, rng.randi() % 2 + 1)
			
			global_transform.origin += Vector3(-100, 0, 0)
		global_transform.origin += Vector3(100 * room_cols, 0, 100)
