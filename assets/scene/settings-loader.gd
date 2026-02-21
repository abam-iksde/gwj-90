extends Node


func _ready() -> void:
	GameSettings.load_settings()
	get_tree().change_scene_to_file.call_deferred('res://assets/scene/main-menu.tscn')
