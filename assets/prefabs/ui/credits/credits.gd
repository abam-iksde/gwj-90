extends TextureRect


func on_show(_payload):
	GameState.mouse_capture.unfocus_mouse()


func on_hide():
	pass


func _ready():
	(get_node('button-exit') as Button).pressed.connect(func():
		(get_node('button-exit') as Button).disabled = true
		var tween: Tween = get_node('../fade').fade_out()
		tween.tween_callback(func():
			get_tree().paused = false
			get_tree().change_scene_to_file('res://assets/scene/main-menu.tscn')
		)
	)
