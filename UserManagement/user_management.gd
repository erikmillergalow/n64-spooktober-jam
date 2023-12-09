extends Node2D

#@onready var create_account = $Panel/CreateAccountPanel


func _ready():
	$Panel/UsernameEdit.grab_focus()
	SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
	SilentWolf.Auth.sw_logout_complete.connect(_on_logout_completed)
	
	await SilentWolf.Auth.auto_login_player().sw_session_check_complete
	
	if SilentWolf.Auth.logged_in_player:
		$Panel/SignedInPanel/SignedInAs.text = str(SilentWolf.Auth.logged_in_player)
		$Panel/WolfStatus.text = "Signed-in successfully, signed in as: " + str(str(SilentWolf.Auth.logged_in_player))
		$Panel/SignedInPanel.visible = true
		
		# sometimes loads in background, don't want to grab focus then 
		if get_parent().visible:
			$Panel/SignedInPanel/SignOut.grab_focus()
		fetch_top_scores()
		

# silent wolf
func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		$Panel/CreateAccountPanel/WolfStatus.text = "Registration complete! Return to last screen to sign in."
	else:
		$Panel/CreateAccountPanel/WolfStatus.text = "Error: " + str(sw_result.error)


func _on_login_complete(sw_result: Dictionary) -> void:
	print("login complete")
	if sw_result.success:
		$Panel/SignedInPanel/SignedInAs.text = str(SilentWolf.Auth.logged_in_player)
		$Panel/WolfStatus.text = "Signed-in successfully, signed in as: " + str(str(SilentWolf.Auth.logged_in_player))
		$Panel/SignedInPanel.visible = true
		$Panel/SignedInPanel/SignOut.grab_focus()
		fetch_top_scores()
	else:
		$Panel/WolfStatus.text = "Error: " + str(sw_result.error)


func format_time(time):
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 3600) / 60
	var elapsed = "%02d : %02d" % [minutes, seconds]
	return elapsed


func fetch_top_scores():
	$Panel/SignedInPanel/ThreesLabelRight.text = "Loading..."
	$Panel/SignedInPanel/FivesLabelRight.text = "Loading..."
	$Panel/SignedInPanel/TensLabelRight.text = "Loading..."
	
	var player_name = SilentWolf.Auth.logged_in_player
	
	var threes_result = await SilentWolf.Scores.get_top_score_by_player(player_name, 1000, '3x3').sw_top_player_score_complete
	if !threes_result.top_score.is_empty():
		var place_result = await SilentWolf.Scores.get_score_position(threes_result.top_score.score_id, '3x3').sw_get_position_complete
		var place = str(place_result.position)
		set_medal_color($Panel/SignedInPanel/ThreesLabelLeft, $Panel/SignedInPanel/ThreesLabelRight, place_result)
		var time = format_time(threes_result.top_score.score)
		var exp = str(threes_result.top_score.metadata.total_exp)
		var seed = str(threes_result.top_score.metadata.seed)
		$Panel/SignedInPanel/ThreesLabelLeft.text = "Place: %s\nEXP: %s" % [place, exp]
		$Panel/SignedInPanel/ThreesLabelRight.text = "Time: %s\nSeed: %s" % [time, seed]
	else:
		$Panel/SignedInPanel/ThreesLabelRight.text = "N/A"
		
	var fives_result = await SilentWolf.Scores.get_top_score_by_player(player_name, 1000, '5x5').sw_top_player_score_complete 
	if !fives_result.top_score.is_empty():
		var place_result = await SilentWolf.Scores.get_score_position(fives_result.top_score.score_id, '5x5').sw_get_position_complete
		var place = str(place_result.position)
		set_medal_color($Panel/SignedInPanel/FivesLabelLeft, $Panel/SignedInPanel/FivesLabelRight, place_result)
		var time = format_time(fives_result.top_score.score)
		var exp = str(fives_result.top_score.metadata.total_exp)
		var seed = str(fives_result.top_score.metadata.seed)
		$Panel/SignedInPanel/FivesLabelLeft.text = "Place: %s\nEXP: %s" % [place, exp]
		$Panel/SignedInPanel/FivesLabelRight.text = "Time: %s\nSeed: %s" % [time, seed]
	else:
		$Panel/SignedInPanel/FivesLabelRight.text = "N/A"
		
	var tens_result = await SilentWolf.Scores.get_top_score_by_player(player_name, 1000, '10x10').sw_top_player_score_complete 
	if !tens_result.top_score.is_empty():
		var place_result = await SilentWolf.Scores.get_score_position(tens_result.top_score.score_id, '10x10').sw_get_position_complete
		var place = str(place_result.position)
		set_medal_color($Panel/SignedInPanel/TensLabelLeft, $Panel/SignedInPanel/TensLabelRight, place_result)
		var time = format_time(fives_result.top_score.score)
		var exp = str(fives_result.top_score.metadata.total_exp)
		var seed = str(fives_result.top_score.metadata.seed)
		$Panel/SignedInPanel/TensLabelLeft.text = "Place: %s\nEXP: %s" % [place, exp]
		$Panel/SignedInPanel/TensLabelRight.text = "Time: %s\nSeed: %s" % [time, seed]
	else:
		$Panel/SignedInPanel/TensLabelRight.text = "N/A"


func set_medal_color(left_label, right_label, place_result):
	if place_result.position == 1:
		left_label.set("theme_override_colors/font_color", Color(0.58663862943649, 0.53361642360687, 0.2308477461338))
		right_label.set("theme_override_colors/font_color", Color(0.58663862943649, 0.53361642360687, 0.2308477461338))
	elif place_result.position == 2:
		left_label.set("theme_override_colors/font_color", Color(0.54953289031982, 0.5542648434639, 0.55309623479843))
		right_label.set("theme_override_colors/font_color", Color(0.54953289031982, 0.5542648434639, 0.55309623479843))
	elif place_result.position == 3:
		left_label.set("theme_override_colors/font_color", Color(0.54256808757782, 0.38000530004501, 0.14970815181732))
		right_label.set("theme_override_colors/font_color", Color(0.54256808757782, 0.38000530004501, 0.14970815181732))
	else:
		left_label.set("theme_override_colors/font_color", Color(0.95850604772568, 0.95575171709061, 0.95048373937607))
		right_label.set("theme_override_colors/font_color", Color(0.95850604772568, 0.95575171709061, 0.95048373937607))

func _on_logout_completed() -> void:
	print("logout complete")
	$Panel/WolfStatus.text = "Signed-out successfully." + str(str(SilentWolf.Auth.logged_in_player))
	$Panel/SignedInPanel.visible = false
	$Panel/UsernameEdit.grab_focus()


func _process(delta):
	pass


func _on_create_account_pressed():
	$Panel/CreateAccountPanel.visible = true
	$Panel/CreateAccountPanel/UsernameEdit.grab_focus()


func _on_cancel_pressed():
	$Panel/CreateAccountPanel.visible = false
	$Panel/UsernameEdit.grab_focus()


func _on_submit_pressed():
	$Panel/CreateAccountPanel/WolfStatus.text = 'Loading...'
	if $Panel/CreateAccountPanel/PasswordEdit.text != $Panel/CreateAccountPanel/ConfirmPasswordEdit.text:
		$Panel/CreateAccountPanel/WolfStatus.text = "Mismatched passwords"
	else:
		var player_name = $Panel/CreateAccountPanel/UsernameEdit.text
		var email = $Panel/CreateAccountPanel/EmailEdit.text
		var password = $Panel/CreateAccountPanel/PasswordEdit.text
		var confirm_password = $Panel/CreateAccountPanel/ConfirmPasswordEdit.text
		SilentWolf.Auth.register_player(player_name, email, password, confirm_password)


func _on_sign_in_pressed():
	$Panel/CreateAccountPanel/WolfStatus.text = 'Loading...'
	var username = $Panel/UsernameEdit.text
	var password = $Panel/PasswordEdit.text
	var stay_signed_in = $Panel/StaySignedInCheckbox.button_pressed
	SilentWolf.Auth.login_player(username, password, stay_signed_in)


func _on_sign_out_pressed():
	print('sign out')
	SilentWolf.Auth.logout_player()
