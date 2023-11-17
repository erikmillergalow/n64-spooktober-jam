extends Node2D

@onready var entry_scene = load("res://Leaderboard/leaderboard_entry.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_scores(scores):
	for child in $Panel/VBoxContainer.get_children():
		child.queue_free()
	
	for i in range(0, scores.size()):
		print(scores[i])
		var entry = entry_scene.instantiate()
		entry.set_fields(i, scores[i])
		$Panel/VBoxContainer.add_child(entry)


func fetch_scores(size):
	if !$Panel/Loading.visible:
		$Panel/VBoxContainer.visible = false
		$Panel/Loading.visible = true
		
		if size == 1:
			$Panel/Title.text = "3x3 WORLD RECORDS"
			var sw_result = await SilentWolf.Scores.get_scores(0, "3x3").sw_get_scores_complete
			var scores = sw_result.scores
			set_scores(scores)
			$Panel/VBoxContainer.visible = true
			$Panel/Loading.visible = false
		elif size == 2:
			$Panel/Title.text = "5x5 WORLD RECORDS"
			var sw_result = await SilentWolf.Scores.get_scores(0, "5x5").sw_get_scores_complete
			var scores = sw_result.scores
			set_scores(scores)
			$Panel/VBoxContainer.visible = true
			$Panel/Loading.visible = false
		elif size == 3:
			$Panel/Title.text = "10x10 WORLD RECORDS"
			var sw_result = await SilentWolf.Scores.get_scores(0, "10x10").sw_get_scores_complete
			var scores = sw_result.scores
			set_scores(scores)
			$Panel/VBoxContainer.visible = true
			$Panel/Loading.visible = false
