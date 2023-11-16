extends Node3D


func _ready():
	$Player.play_win_music()


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		$Panel.visible = true
