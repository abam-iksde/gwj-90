class_name WinScreen
extends TextureRect


func on_show(_payload):
	GameState.mouse_capture.unfocus_mouse()


func on_hide():
	pass


func _ready():
	var button := (get_node('button-exit') as Button)
	button.pressed.connect(func():
		button.disabled = true
		GameState.ui.hide_modal()
		await GameState.ui.modal_hidden
		GameState.ui.show_modal(UiContainer.Modal.CREDITS)
	)
	(get_node('button-continue') as Button).pressed.connect(func():
		Sounds.play_click()
		get_tree().paused = false
		GameState.mouse_capture.focus_mouse()
		GameState.ui.hide_modal()
	)
