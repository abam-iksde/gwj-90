@tool
class_name EditorSnowCollider
extends Node3D


@export var regenerate := false:
	set(value):
		_regenerate()





func _regenerate():
	height_map_image = load('res://assets/map/target.png').get_image()
	cleared_image = load('res://assets/map/dig-default.png').get_image()
	height_map_image.decompress()
	cleared_image.decompress()
	var collision_shape := get_node('static-body-3d/collision-shape-3d')
	var mesh := ConcavePolygonShape3D.new()
	var vertices := []
	var x := 0
	while x < height_map_image.get_width():
		var y := 0
		while y < height_map_image.get_height():
			vertices.append(Vector3(
				float(x),
				float(get_ground_height_at_position(Vector3(x, 0, y))),
				float(y),
			))
			vertices.append(Vector3(
				float(x+1),
				float(get_ground_height_at_position(Vector3(x+1, 0, y))),
				float(y),
			))
			vertices.append(Vector3(
				float(x),
				float(get_ground_height_at_position(Vector3(x, 0, y+1))),
				float(y+1),
			))
			
			vertices.append(Vector3(
				float(x+1),
				float(get_ground_height_at_position(Vector3(x+1, 0, y))),
				float(y),
			))
			vertices.append(Vector3(
				float(x+1),
				float(get_ground_height_at_position(Vector3(x+1, 0, y+1))),
				float(y+1),
			))
			vertices.append(Vector3(
				float(x),
				float(get_ground_height_at_position(Vector3(x, 0, y+1))),
				float(y+1),
			))
			y += 1
		x += 1
	mesh.backface_collision = true
	mesh.set_faces(PackedVector3Array(vertices))
	ResourceSaver.save(mesh, 'res://generated/snow-collision.res', ResourceSaver.FLAG_COMPRESS)
	collision_shape.shape = load('res://generated/snow-collision.res')


func get_ground_height_at_position(_global_position: Vector3, ignore_dig := false) -> float:
	return get_ground_height_and_elevation_at_position(_global_position, ignore_dig).x


func get_ground_height_and_elevation_at_position(_global_position: Vector3, ignore_dig := false) -> Vector2:
	if (
		_global_position.x < 0.5
		or _global_position.x >= float(Constants.MAP_SIZE) - 0.5
		or _global_position.z < 0.5
		or _global_position.z >= float(Constants.MAP_SIZE) - 0.5
	):
		return Vector2(0.0, 0.0)
	
	var xpos := _global_position.x - 0.5
	var zpos := _global_position.z - 0.5
	
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


var height_map_image
var cleared_image


func _get_height_map_point_height(x: int, y: int, ignore_dig: bool) -> float:
	var height_map_height := color_to_height(
		height_map_image.get_pixel(x, y)
	) * Constants.HEIGHT_MAP_SCALE
	if ignore_dig:
		return height_map_height
	return (
		height_map_height
		if cleared_image.get_pixel(x, y).r < 0.5 else
		0.0
	)

func color_to_height(color: Color) -> float:
	return (
		((color.r + color.g + color.b + color.a) / 4.0 - Constants.HEIGHT_MAP_DATA_BOTTOM_THRESHOLD)
		/ (Constants.HEIGHT_MAP_DATA_TOP_THRESHOLD - Constants.HEIGHT_MAP_DATA_BOTTOM_THRESHOLD)
	)
