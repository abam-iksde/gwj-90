class_name GameWorldEnvironment
extends WorldEnvironment


var times := {
	0.0: TimeOfDay.new(0.8, 0.0, Vector3.ZERO, 7.0, 100.0, Color(0.158, 0.183, 0.27, 1.0), 1.0),
	3.0: TimeOfDay.new(0.8, 0.0, Vector3(0.0, 360.0, 0.0), 7.0, 100.0, Color(0.354, 0.398, 0.546, 1.0), 1.0),
	7.0: TimeOfDay.new(0.7, 0.7, Vector3(-27, 320.0, 0.0), 8.0, 120.0, Color(0.662, 0.701, 0.822, 1.0), 1.0),
	12.0: TimeOfDay.new(1.0, 1.0, Vector3(-40, 270.0, 0.0), 8.0, 180.0, Color(0.745, 0.776, 0.871, 1.0), 1.0),
	16.0: TimeOfDay.new(0.9, 0.9, Vector3(-35, 230.0, 0.0), 8.0, 155.0, Color(0.676, 0.713, 0.831, 1.0), 1.0),
	22.0: TimeOfDay.new(0.9, 0.0, Vector3(-25, 200.0, 0.0), 8.0, 155.0, Color(0.245, 0.279, 0.398, 1.0), 1.0),
}


@onready var sun: DirectionalLight3D = get_node('sun')

var current_time_of_day: TimeOfDay = times[0.0]


func _enter_tree() -> void:
	GameState.environment = self


func _exit_tree() -> void:
	GameState.environment = null


func _ready() -> void:
	_update()


func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		GameState.game_data.time += delta / Constants.HOUR
	GameState.game_data.time = fposmod(GameState.game_data.time, 24.0)
	_update()


func _update() -> void:
	var keys = times.keys()
	keys.sort()
	keys.push_back(keys[0] + 24.0)
	var first_key
	var second_key
	for index in len(keys):
		if keys[index] <= GameState.game_data.time:
			first_key = keys[index]
			second_key = keys[index + 1]
	var first_time = times[first_key]
	var second_time = times[fmod(second_key, 24.0)]
	var interpolation_ratio = (GameState.game_data.time - first_key) / (second_key - first_key)
	current_time_of_day = TimeOfDay.lerp(first_time, second_time, interpolation_ratio)
	environment.background_energy_multiplier = current_time_of_day.ambient_light_energy
	environment.fog_depth_begin = current_time_of_day.fog_start
	environment.fog_depth_end = current_time_of_day.fog_end
	environment.fog_light_color = current_time_of_day.fog_color
	sun.light_energy = current_time_of_day.sun_energy
	sun.rotation_degrees = current_time_of_day.sun_rotation
