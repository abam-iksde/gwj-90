class_name Cold
extends Node


var deplete_outside_per_second = 1.1
var deplete_inside_per_second = 0.5


func _physics_process(delta: float) -> void:
	GameState.game_data.player_health -= (
		(deplete_inside_per_second if GameState.plow.player_in else deplete_outside_per_second)
		* delta
		* GameState.environment.current_time_of_day.cold_scale
	)
	
	if GameState.game_data.player_health < 0.0:
		GameState.game_data.player_health = 0.0
		GameState.notify_player_died()
