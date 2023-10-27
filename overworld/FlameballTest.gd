extends Node3D

@onready var flame_scene = load('res://flame_ball/flameball.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var flame = flame_scene.instantiate()
	flame.global_transform.origin = global_transform.origin
	add_child(flame)
