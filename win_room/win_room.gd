extends Node3D


var new_sign_in = false
var leaderboard_selected = false

var overworld_scene = preload('res://overworld/overworld.tscn')

func _ready():
	$Panel/ElapsedTime.text = "Elapsed time: " + format_time()
	$Panel/TotalExp.text = "Total Exp: " + str(global.total_run_exp)
	
	$Panel/Leaderboard.fetch_scores(global.grid_size)
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
	
	$Player.play_win_music()
	
	if SilentWolf.Auth.logged_in_player:
		upload_score()


func format_time():
	var seconds = fmod(global.elapsed_time, 60)
	var minutes = fmod(global.elapsed_time, 3600) / 60
	var elapsed = "%02d : %02d" % [minutes, seconds]
	return elapsed


func _on_login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		$Panel/WolfResponse.text = "Sign-in successful, uploading score as " + str(SilentWolf.Auth.logged_in_player)
		upload_score()
	else:
		$Panel/WolfResponse.text = "Error: " + str(sw_result.error)


func _process(delta):
	if Input.is_action_just_pressed("interact") and not $Panel.visible:
		$Panel.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Panel/UserManagement/Panel/UsernameEdit.grab_focus()
		
	if $Panel.visible:
		if Input.is_action_just_pressed('ui_right') and not leaderboard_selected:
			$Panel/Leaderboard.focus_at_top()
			leaderboard_selected = true

		if Input.is_action_just_pressed('ui_left') and leaderboard_selected and not global.challenge_options_open:
			$Panel/MainMenuButton.grab_focus()
			leaderboard_selected = false

	if global.challenge_start:
		start_game()

func start_game():
	global.initialize()
#	get_tree().change_scene_to_file('res://overworld/overworld.tscn')
	
	var overworld = overworld_scene.instantiate()
	get_parent().add_child(overworld)
	self.queue_free()


func upload_score():
	var player_name = SilentWolf.Auth.logged_in_player
	var score = 21600000 - (global.elapsed_time * 1000) + global.total_run_exp

	var metadata = {
		"elapsed_time": global.elapsed_time,
		"total_exp": global.total_run_exp,
		"seed": global.seed 
	}
	print('metadata')
	print(metadata)
	var leaderboard = "3x3"
	if global.grid_size == 2:
		leaderboard = "5x5"
	if global.grid_size == 3:
		leaderboard = "10x10"
	
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, score, leaderboard, metadata).sw_save_score_complete
	
	for i in range(0, 50):
		sw_result = await SilentWolf.Scores.save_score(player_name + '_' + str(i), score, leaderboard, metadata).sw_save_score_complete
	
	$Panel/WolfResponse.text = "Score uploaded successfully!"
	$Panel/Leaderboard.fetch_scores(global.grid_size)


func _on_main_menu_button_pressed():
	global.win = false
	get_tree().change_scene_to_file('res://main.tscn')
