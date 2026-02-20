class_name TimeOfDay
extends RefCounted


var ambient_light_energy: float
var sun_energy: float
var sun_rotation: Vector3
var fog_start: float
var fog_end: float
var fog_color: Color
var cold_scale: float


func _init(
	_ambient_light_energy: float,
	_sun_energy: float,
	_sun_rotation: Vector3,
	_fog_start: float,
	_fog_end: float,
	_fog_color: Color,
	_cold_scale: float
):
	ambient_light_energy = _ambient_light_energy
	sun_energy = _sun_energy
	sun_rotation = _sun_rotation
	fog_start = _fog_start
	fog_end = _fog_end
	fog_color = _fog_color
	cold_scale = _cold_scale


static func lerp(a: TimeOfDay, b: TimeOfDay, ratio: float) -> TimeOfDay:
	return TimeOfDay.new(
		lerpf(a.ambient_light_energy, b.ambient_light_energy, ratio),
		lerpf(a.sun_energy, b.sun_energy, ratio),
		Vector3(
			lerpf(a.sun_rotation.x, b.sun_rotation.x, ratio),
			lerpf(a.sun_rotation.y, b.sun_rotation.y, ratio),
			lerpf(a.sun_rotation.z, b.sun_rotation.z, ratio)
		),
		lerpf(a.fog_start, b.fog_start, ratio),
		lerpf(a.fog_end, b.fog_end, ratio),
		a.fog_color.lerp(b.fog_color, ratio),
		lerpf(a.cold_scale, b.cold_scale, ratio)
	)
