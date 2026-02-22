extends Node


@onready var parent = get_parent()


var showing_tutorial := false


func _ready() -> void:
	if GameState.game_data.tutorials_enabled:
		_on_tutorial_shown(null, null, null)
		GameState.tutorial_requested.connect(_on_tutorial_shown)


func _input(event: InputEvent) -> void:
	if GameState.game_data.player_dead:
		return
	if not event.is_action(&'open_map'):
		return
	if parent.settings_visible:
		return
	if event.is_pressed():
		try_toggle_map()


func try_toggle_map() -> void:
	if showing_tutorial:
		return
	if GameState.ui.sliding:
		return
	if not GameState.ui.visible_modal:
		GameState.ui.show_modal(UiContainer.Modal.MAP, { &'show_respawn_options': false })
	elif GameState.ui.visible_modal == get_parent() and not GameState.game_data.player_dead:
		GameState.ui.hide_modal()


func _on_tutorial_shown(_id, _unpause_on_continue, _capture_mouse_on_continue):
	showing_tutorial = true
	await GameState.tutorial_hidden
	showing_tutorial = false
