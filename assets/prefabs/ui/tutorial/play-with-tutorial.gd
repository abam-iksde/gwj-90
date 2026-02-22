class_name PlayWithTutorialDialog
extends Control


@onready var container: TextureRect = get_node('texture-rect')

@onready var button_yes: Button = get_node('texture-rect/button-yes')
@onready var button_no: Button = get_node('texture-rect/button-no')
@onready var button_cancel: Button = get_node('texture-rect/button-cancel')


func _ready() -> void:
	_on_resize()
	get_viewport().size_changed.connect(_on_resize)


func _on_resize():
	var viewport_size := Vector2(get_viewport().size)
	var _scale := viewport_size.y * 0.6 / container.size.y
	container.scale = Vector2(_scale, _scale)
	container.position = (viewport_size - container.size * container.scale) / 2.0
