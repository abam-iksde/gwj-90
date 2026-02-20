extends Label


func _physics_process(_delta: float) -> void:
	text = "health: " + str(int(GameState.game_data.player_health)) + '%\n'
	text += 'fuel in plow: ' + str(GameState.plow.fuel) + '%\n'
	text += 'food in inventory: ' + str(GameState.game_data.player_food) + '\n'
	text += 'fuel in inventory: ' + str(GameState.game_data.player_fuel) + '\n'
