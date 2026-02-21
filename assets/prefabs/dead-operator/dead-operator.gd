extends Node3D


@onready var raycast: RayCast3D = get_node('ray-cast-3d')


func update_position() -> void:
	raycast.force_raycast_update()
	var raycast_position = global_position - Vector3(0.0, 700.0, 0.0)
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider is Plow:
			raycast.add_exception(collider)
			update_position()
			return
		raycast_position = raycast.get_collision_point()
	var ground_height := GroundUtil.get_ground_height_at_position(global_position)
	if ground_height <= Plow.MAX_SNOW_HEIGHT:
		ground_height = -700.0
	global_position.y = maxf(raycast_position.y, ground_height)
