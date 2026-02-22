class_name FoodManager
extends Node


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&'eat') and GameState.game_data.player_food > 0 and not GameState.game_data.player_dead:
		Sounds.play_eat()
		GameState.game_data.player_food -= 1
		GameState.game_data.player_health = minf(
			GameState.game_data.player_health + Constants.FOOD_HEALTH_BONUS,
			Constants.PLAYER_MAX_HEALTH
		)
