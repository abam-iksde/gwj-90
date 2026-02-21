extends Interactable


@onready var plow: Plow = get_parent()


func get_action_name() -> String:
	return 'Get in'


func interact() -> void:
	plow.player_in = true
	plow.camera.make_current()
	if GameState.player:
		GameState.player.queue_free()
