extends Interactable


@onready var plow: Plow = get_parent()


func get_action_name() -> String:
	return 'Get in'


func interact() -> void:
	plow.audio_state = Plow.AudioState.IDLE
	Sounds.start_engine_sounds()
	plow.player_in = true
	plow.camera.make_current()
	if GameState.player:
		plow.camera_target.global_rotation = GameState.player.camera.global_rotation
		GameState.player.queue_free()
