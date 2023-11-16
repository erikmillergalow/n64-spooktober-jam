extends ProgressBar


func _ready():
	max_value = 1.0


func _process(delta):
	if max_value != global.max_stats_level:
		var tween = create_tween()
		tween.tween_property(self, "max_value", global.max_stats_level, 0.5)
	
	
	if value != global.run_speed_modifier:
		var fill_tween = create_tween()
		fill_tween.tween_property(self, "value", global.run_speed_modifier, 0.5)
