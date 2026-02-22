extends Node


func _ready() -> void:
	GameSettings.load_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Master'), GameSettings.VOLUME)
	get_tree().change_scene_to_file.call_deferred('res://assets/scene/main-menu.tscn')
