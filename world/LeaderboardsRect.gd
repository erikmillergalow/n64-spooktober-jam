extends Panel

var loading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func open():
	visible = true
	$SizeSlider.value = 1
	fetch_leaderboard(1)

func close():
	visible = false


func fetch_leaderboard(size):
	$Leaderboard/Panel/VBoxContainer.visible = false
	$Leaderboard/Panel/Loading.visible = true
	
	if size == 1:
		var sw_result = await SilentWolf.Scores.get_scores(0, "3x3").sw_get_scores_complete
		var scores = sw_result.scores
		$Leaderboard.set_scores(scores)
		$Leaderboard/Panel/VBoxContainer.visible = true
		$Leaderboard/Panel/Loading.visible = false
	elif size == 2:
		var sw_result = await SilentWolf.Scores.get_scores(0, "5x5").sw_get_scores_complete
		var scores = sw_result.scores
		$Leaderboard.set_scores(scores)
		$Leaderboard/Panel/VBoxContainer.visible = true
		$Leaderboard/Panel/Loading.visible = false
	elif size == 3:
		var sw_result = await SilentWolf.Scores.get_scores(0, "10x10").sw_get_scores_complete
		var scores = sw_result.scores
		$Leaderboard.set_scores(scores)
		$Leaderboard/Panel/VBoxContainer.visible = true
		$Leaderboard/Panel/Loading.visible = false
	
