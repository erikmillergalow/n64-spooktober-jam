extends Area3D

@onready var global = get_node("/root/global")

var open_texture = load('res://key_chest/key_chest_open.png')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group('player'):
		if not global.has_key:
			$Open.play()
		
		global.has_key = true
		$Sprite3D.texture = open_texture
		body.show_key_alert()
