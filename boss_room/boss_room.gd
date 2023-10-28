extends Node3D

@onready var global = get_node('/root/global')


func _ready():
	$RoomWall.close_laser_gate()
	$RoomWall2.close_laser_gate()
	$RoomWall3.close_laser_gate()
	$EyeballBoss.set_player(get_parent().get_node('Player'))


func _process(delta):
	if global.has_key:
		$Entrance/StaticBody3D.set_collision_layer_value(1, false)
		$Entrance/StaticBody3D.set_collision_mask_value(1, false)


func _on_player_sensor_body_entered(body):
	if body.is_in_group('player'):
		body.show_door_text()
		
		if global.has_key and $Entrance.visible:
			$OpenDoor.play()
			$Entrance.visible = false
			body.stop_music()


func _on_player_sensor_body_exited(body):
	if body.is_in_group('player'):
		body.hide_door_text()


#func _on_player_entered_sensor_body_entered(body):
#	if body.is_in_group('player'):
		
#		body.play_boss_music()
