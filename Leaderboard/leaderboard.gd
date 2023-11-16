extends Node2D

@onready var entry_scene = load("res://Leaderboard/leaderboard_entry.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_scores(scores):
	for score in scores:
		var entry = entry_scene.instantiate()
		entry.set_fields(score)
		$Panel/VBoxContainer.add_child(entry)
