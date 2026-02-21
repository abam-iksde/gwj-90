extends Control


@export var scale_factor = 1.0


func _ready() -> void:
	_on_resize()
	get_viewport().size_changed.connect(_on_resize)


func _on_resize() -> void:
	var _scale = get_viewport().size.y / 900.0 * scale_factor
	scale = Vector2(_scale, _scale)
