extends Node2D

#@onready var create_account = $Panel/CreateAccountPanel


func _ready():
	$Panel/UsernameEdit.grab_focus()
	SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)


# silent wolf
func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		$Panel/CreateAccountPanel/WolfStatus.text = "Registration complete! Return to last screen to sign in."
	else:
		$Panel/CreateAccountPanel/WolfStatus.text = "Error: " + str(sw_result.error)


func _on_login_complete(sw_result: Dictionary) -> void:
	print("login complete")
	if sw_result.success:
		$Panel/WolfStatus.text = "Signed-in successfully, signed in as: " + str(str(SilentWolf.Auth.logged_in_player))
	else:
		$Panel/WolfStatus.text = "Error: " + str(sw_result.error)


func _process(delta):
	pass


func _on_create_account_pressed():
	$Panel/CreateAccountPanel.visible = true
	$Panel/CreateAccountPanel/UsernameEdit.grab_focus()


func _on_cancel_pressed():
	$Panel/CreateAccountPanel.visible = false
	$Panel/UsernameEdit.grab_focus()


func _on_submit_pressed():
	if $Panel/CreateAccountPanel/PasswordEdit.text != $Panel/CreateAccountPanel/ConfirmPasswordEdit.text:
		$Panel/CreateAccountPanel/WolfStatus.text = "Mismatched passwords"
	else:
		var player_name = $Panel/CreateAccountPanel/UsernameEdit.text
		var email = $Panel/CreateAccountPanel/EmailEdit.text
		var password = $Panel/CreateAccountPanel/PasswordEdit.text
		var confirm_password = $Panel/CreateAccountPanel/ConfirmPasswordEdit.text
		SilentWolf.Auth.register_player(player_name, email, password, confirm_password)


func _on_sign_in_pressed():
	var username = $Panel/UsernameEdit.text
	var password = $Panel/PasswordEdit.text
	SilentWolf.Auth.login_player(username, password)
