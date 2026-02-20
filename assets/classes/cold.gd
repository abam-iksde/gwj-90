class_name Cold
extends Node


func _physics_process(delta: float) -> void:
	GameState.game_data.player_health -= (
		(Constants.HEALTH_DEPLETE_INSIDE if GameState.plow.player_in else Constants.HEALTH_DEPLETE_OUTSIDE)
		* delta
		* GameState.environment.current_time_of_day.cold_scale
	)
	
	if GameState.game_data.player_health < 0.0:
		GameState.game_data.player_health = 0.0
		GameState.notify_player_died()
