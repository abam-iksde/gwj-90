extends TextureRect


func _ready() -> void:
	update()


func _process(_delta: float) -> void:
	update()


func update():
	modulate.a = maxf(1.0 - GameState.game_data.player_health / 100.0 * 5.0, 0.0)
