extends Node3D


var new_sign_in = false


func _ready():
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
	$Player.play_win_music()
	
	if SilentWolf.Auth.logged_in_player:
		upload_score()
		$Leaderboard.fetch_scores(global.grid_size)


func _on_login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		$Panel/WolfResponse.text = "Sign-in successful, uploading score as " + str(SilentWolf.Auth.logged_in_player)
		upload_score()
	else:
		$Panel/WolfResponse.text = "Error: " + str(sw_result.error)


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		$Panel.visible = true


func upload_score():
	var player_name = SilentWolf.Auth.logged_in_player
	var score = global.elapsed_time + global.total_run_exp
#	var combined_score = (9223372036854775800 - global.elapsed_time) + (global.total_run_exp / 1500000)
#	SilentWolf.Scores.save_score(player_name, combined_score)
	var metadata = {
		"elapsed_time": global.elapsed_time,
		"total_exp": global.total_run_exp
	}
	var leaderboard = "3x3"
	if global.grid_size == 2:
		leaderboard = "5x5"
	if global.grid_size == 3:
		leaderboard = "10x10"
	
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, score, leaderboard, metadata).sw_save_score_complete
	$Panel/WolfResponse.text = "Score uploaded successfully!"
