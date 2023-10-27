extends Node3D

@onready var global = get_node('/root/global')


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.has_key:
		$Entrance/StaticBody3D.set_collision_layer_value(1, false)
		$Entrance/StaticBody3D.set_collision_mask_value(1, false)
		$Entrance.visible = false



func _on_player_sensor_body_entered(body):
	if body.is_in_group('player'):
		body.show_door_text()


func _on_player_sensor_body_exited(body):
	if body.is_in_group('player'):
		body.hide_door_text()
