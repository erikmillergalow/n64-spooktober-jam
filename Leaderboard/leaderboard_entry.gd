extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func format_time(time):
	var seconds = fmod(time, 60)
	var minutes = fmod(time, 3600) / 60
	var elapsed = "%02d : %02d" % [minutes, seconds]
	return elapsed


func set_fields(index, score):
	var time = format_time(score.metadata.elapsed_time)
	$HBoxContainer/PlaceLabel.text = "#" + str(index + 1)
	$HBoxContainer/NameLabel.text = score.player_name
	$HBoxContainer/TimeLabel.text = time
	$HBoxContainer/ExpLabel.text = str(score.metadata.total_exp)
