class_name Fade
extends ColorRect


func _ready() -> void:
	fade_in()


func fade_in() -> Tween:
	color = Color(0.0, 0.0, 0.0, 1.0)
	var tween := create_tween()
	tween.tween_property(self, 'color', Color(0.0, 0.0, 0.0, 0.0), 1.0)
	return tween


func fade_out() -> Tween:
	color = Color(0.0, 0.0, 0.0, 0.0)
	var tween := create_tween()
	tween.tween_property(self, 'color', Color(0.0, 0.0, 0.0, 1.0), 1.0)
	return tween
