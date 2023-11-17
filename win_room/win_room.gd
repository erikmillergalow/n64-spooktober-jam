extends Node3D


var new_sign_in = false


func _ready():
	$Panel/ElapsedTime.text = "Elapsed time: " + format_time()
	$Panel/TotalExp.text = "Total Exp: " + str(global.total_run_exp)
	
	$Panel/Leaderboard.fetch_scores(global.grid_size)
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
	
	$Player.play_win_music()
	
	if SilentWolf.Auth.logged_in_player:
		upload_score()
#		$Panel/Leaderboard.fetch_scores(global.grid_size)

func format_time():
	var seconds = fmod(global.elapsed_time, 60)
	var minutes = fmod(global.elapsed_time, 3600) / 60
	var elapsed = "%02d : %02d" % [minutes, seconds]
	return elapsed


func _on_login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		$Panel/WolfResponse.text = "Sign-in successful, uploading score as " + str(SilentWolf.Auth.logged_in_player)
		upload_score()
#		$Panel/Leaderboard.fetch_scores(global.grid_size)
	else:
		$Panel/WolfResponse.text = "Error: " + str(sw_result.error)


func _process(delta):
	if Input.is_action_just_pressed("interact") and not $Panel.visible:
		$Panel.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Panel/UserManagement/Panel/UsernameEdit.grab_focus()


func upload_score():
	var player_name = SilentWolf.Auth.logged_in_player
	var score = 21600000 - global.elapsed_time + global.total_run_exp

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
	$Panel/Leaderboard.fetch_scores(global.grid_size)


func _on_main_menu_button_pressed():
	global.win = false
	get_tree().change_scene_to_file('res://main.tscn')
