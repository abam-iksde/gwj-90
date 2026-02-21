extends Node


func _input(event: InputEvent) -> void:
	if GameState.game_data.player_dead:
		return
	if not event.is_action(&'open_map'):
		return
	if event.is_pressed():
		try_toggle_map()


func try_toggle_map() -> void:
	if GameState.ui.sliding:
		return
	if not GameState.ui.visible_modal:
		GameState.ui.show_modal(UiContainer.Modal.MAP, { &'show_respawn_options': false })
	elif GameState.ui.visible_modal == get_parent() and not GameState.game_data.player_dead:
		GameState.ui.hide_modal()
