extends ProgressBar


func _ready():
	pass


func _process(delta):
	var tween = create_tween()
	if max_value != global.max_stats_level:
		tween.tween_property(self, "max_value", global.max_stats_level, 0.5)
	
	
	var fill_tween = create_tween()
	if value != ((global.spell_speed_modifier * 2) - 1):
		fill_tween.tween_property(self, "value", ((global.spell_speed_modifier * 2) - 1), 0.5)
