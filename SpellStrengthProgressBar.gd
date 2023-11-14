extends ProgressBar


func _ready():
	pass # Replace with function body.


func _process(delta):
	var tween = create_tween()
	if max_value != global.max_stats_level:
		tween.tween_property(self, "max_value", global.max_stats_level, 0.5)
	
	var fill_tween = create_tween()
	if value != global.spell_power_modifier:
		fill_tween.tween_property(self, "value", global.spell_power_modifier, 0.5)
