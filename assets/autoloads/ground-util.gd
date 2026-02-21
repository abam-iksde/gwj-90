class_name GroundUtil
extends Object


static func get_ground_height_at_position(global_position: Vector3, ignore_dig := false) -> float:
	return get_ground_height_and_elevation_at_position(global_position, ignore_dig).x


static func get_ground_height_and_elevation_at_position(global_position: Vector3, ignore_dig := false) -> Vector2:
	if (
		global_position.x < 0.5
		or global_position.x >= float(Constants.MAP_SIZE) - 0.5
		or global_position.z < 0.5
		or global_position.z >= float(Constants.MAP_SIZE) - 0.5
	):
		return Vector2(0.0, 0.0)
	
	var xpos := global_position.x - 0.5
	var zpos := global_position.z - 0.5
	
	var x_ratio := fmod(xpos, 1.0)
	
	var a := _get_height_map_point_height(floori(xpos), floori(zpos), ignore_dig)
	var b := _get_height_map_point_height(ceili(xpos), floori(zpos), ignore_dig)
	var c := _get_height_map_point_height(floori(xpos), ceili(zpos), ignore_dig)
	var d := _get_height_map_point_height(ceili(xpos), ceili(zpos), ignore_dig)
	
	var height := lerpf(
		lerpf(a, b, x_ratio),
		lerpf(c, d, x_ratio),
		fmod(zpos, 1.0)
	)
	
	var elevation := maxf(a, maxf(b, maxf(c, d))) - minf(a, minf(b, minf(c, d)))
	
	return Vector2(height, elevation)


static func _get_height_map_point_height(x: int, y: int, ignore_dig: bool) -> float:
	var height_map_height := color_to_height(
		GameState.height_map_image.get_pixel(x, y)
	) * Constants.HEIGHT_MAP_SCALE
	if ignore_dig:
		return height_map_height
	return (
		height_map_height
		if GameState.game_data.cleared_image.get_pixel(x, y).r < 0.5 else
		0.0
	)


static func color_to_height(color: Color) -> float:
	return (
		((color.r + color.g + color.b + color.a) / 4.0 - Constants.HEIGHT_MAP_DATA_BOTTOM_THRESHOLD)
		/ (Constants.HEIGHT_MAP_DATA_TOP_THRESHOLD - Constants.HEIGHT_MAP_DATA_BOTTOM_THRESHOLD)
	)
