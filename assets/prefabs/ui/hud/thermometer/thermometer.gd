extends TextureProgressBar


const MIN_PROGRESS = 28.0
const MAX_PROGRESS = 81.0

const WARM_COLOR = Color('991C05')
const COLD_COLOR = Color('0777A5')


var max_temperature: float = INF
var min_temperature: float = -INF


func _ready() -> void:
	for time in GameState.environment.times.values():
		if time.cold_scale > min_temperature:
			min_temperature = time.cold_scale
		if time.cold_scale < max_temperature:
			max_temperature = time.cold_scale
	
	update()


func _physics_process(_delta: float) -> void:
	update()


func update():
	value = lerpf(MIN_PROGRESS, MAX_PROGRESS, _get_temperature_lerp_ratio())
	tint_progress = COLD_COLOR.lerp(WARM_COLOR, _get_temperature_lerp_ratio())


func _get_temperature_lerp_ratio():
	return (GameState.environment.current_time_of_day.cold_scale - min_temperature) / (max_temperature - min_temperature)
