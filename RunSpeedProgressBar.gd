extends ProgressBar


func _ready():
	max_value = 1.0


func _process(delta):
	var tween = create_tween()
	if max_value != global.max_stats_level:
		tween.tween_property(self, "max_value", global.max_stats_level, 0.5)
	
	
	var fill_tween = create_tween()
	if value != global.run_speed_modifier:
		fill_tween.tween_property(self, "value", global.run_speed_modifier, 0.5)
