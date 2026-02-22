class_name SnowCharacter
extends CharacterBody3D


var _ground_elevation := 0.0
var _fall_velocity := 0.0
var _fallen_high := false
var _is_on_snow := false
var _is_on_slope := false


func is_on_ground() -> bool:
	return is_on_floor() or _is_on_snow


func move_and_slide_with_snow():
	_fallen_high = false
	_ground_elevation = 0.0
	var was_on_ground := is_on_ground()
	_fall_velocity = velocity.y
	move_and_slide()
	var ground_height_and_elevation := GroundUtil.get_ground_height_and_elevation_at_position(global_position)
	var ground_height := ground_height_and_elevation.x
	_ground_elevation = ground_height_and_elevation.y
	if (global_position.y - (floor_snap_length if was_on_ground else 0.0)) <= ground_height:
		global_position.y = ground_height
		velocity.y = 0.0
		_is_on_snow = true
		_is_on_slope = _ground_elevation > 1.5
	else:
		_is_on_snow = false
		_is_on_slope = false
	
	if is_on_ground() and _fall_velocity <= -4.0:
		_fallen_high = true
