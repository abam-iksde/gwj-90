class_name WinTrigger
extends Area3D


func _on_body_enter(body: Node) -> void:
	var plow := body as Plow
	if not plow:
		return
	
	GameState.ui.show_modal(UiContainer.Modal.WIN_SCREEN)
	get_tree().paused = true


func _ready() -> void:
	body_entered.connect(_on_body_enter)
