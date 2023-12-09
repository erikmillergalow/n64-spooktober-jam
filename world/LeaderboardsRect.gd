extends Panel

var loading = false
var leaderboard_selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('ui_right') and not leaderboard_selected and visible:
		$Leaderboard.focus_at_top()
		leaderboard_selected = true
		
	if Input.is_action_just_pressed('ui_left') and leaderboard_selected and visible and not global.challenge_options_open:
		$LeaderboardDoneButton.grab_focus()
		leaderboard_selected = false


func open():
	visible = true
	$SizeSlider.value = 1
	$Leaderboard.fetch_scores(1)


func close():
	visible = false


func _on_size_slider_value_changed(value):
	$Leaderboard.fetch_scores(value)
