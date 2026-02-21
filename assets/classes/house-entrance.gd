extends Interactable


func get_action_name() -> String:
	return tr('Enter')


func interact() -> void:
	GameState.ui.show_modal(UiContainer.Modal.INTERIOR)


func _ready() -> void:
	GameState.game_data.houses.push_back(self)
