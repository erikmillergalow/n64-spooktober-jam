extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_fields(score):
	$HBoxContainer/NameLabel.text = score.player_name
	$HBoxContainer/TimeLabel.text = score.metadata.elapsed_time
	$HBoxContainer/ExpLabel.text = score.metadata.total_exp
