extends StaticBody3D

@onready var gate = get_parent().get_node("Gate2D")


func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func open_gate():
	print('opening laser gate')
	set_collision_layer_value(1, false)
	gate.visible = false
	if $CollisionShape3D:
		$CollisionShape3D.queue_free()
