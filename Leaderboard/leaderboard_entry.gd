extends Panel


var run_seed


func _ready():
	pass


func _process(delta):
	pass

func format_time(time):
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 3600) / 60
	var elapsed = "%02d : %02d" % [minutes, seconds]
	return elapsed


func set_fields(index, score):
	run_seed = score.metadata.seed
	var time = format_time(score.metadata.elapsed_time)
	$HBoxContainer/PlaceLabel.text = "#" + str(index + 1)
	$HBoxContainer/NameLabel.text = score.player_name
	$HBoxContainer/TimeLabel.text = time
	$HBoxContainer/ExpLabel.text = str(score.metadata.total_exp)
	$ChallengeRun/PlayerValue.text = score.player_name
	$ChallengeRun/TimeValue.text = time
	$ChallengeRun/ExpValue.text = str(score.metadata.total_exp)
	$ChallengeRun/SeedValue.text = str(score.metadata.seed)


func challenge_focus():
	$HBoxContainer/Button.grab_focus()


func _on_button_pressed():
	global.challenge_options_open = true
	$ChallengeRun.visible = true
	$ChallengeRun/BackButton.grab_focus()


func _on_back_button_pressed():
	$ChallengeRun.visible = false
	$HBoxContainer/Button.grab_focus()


func _on_begin_button_pressed():
	global.seed = $ChallengeRun/SeedValue.text
	global.challenge_start = true
