extends Node3D


@onready var camera: Camera3D = get_node('camera')
@onready var camera_target: Node3D = get_node('camera-target')
@onready var animation_player: AnimationPlayer = get_node('animation-player')
@onready var wall_ray_cast: RayCast3D = get_node('wall-ray-cast')


func _ready() -> void:
	GameState.player_spawned.connect(_on_player_spawned)


func play() -> void:
	camera.make_current()
	animation_player.play(&'die')
	var original_camera_rotation := camera.rotation
	var camera_sync_tween := create_tween()
	camera_sync_tween.tween_method(camera_rotation_lerp.bind(original_camera_rotation), 0.0, 1.0, 1.5)
	camera_sync_tween.tween_method(camera_rotation_lerp.bind(Vector3.ZERO), 1.0, 1.0, 4.5)
	camera_sync_tween.tween_callback(
		func(): GameState.ui.show_modal(UiContainer.Modal.MAP, { &'show_respawn_options': true })
	)


func camera_rotation_lerp(ratio: float, original_camera_rotation: Vector3) -> void:
	wall_ray_cast.position.y = camera_target.position.y
	wall_ray_cast.force_raycast_update()
	camera.rotation = original_camera_rotation.lerp(camera_target.rotation, ratio)
	camera.position.x = camera_target.position.x
	if wall_ray_cast.is_colliding():
		camera.position.z = maxf(camera_target.position.z, to_local(wall_ray_cast.get_collision_point()).z + 0.5)
	else:
		camera.position.z = camera_target.position.z
	
	camera.global_position.y = maxf(camera_target.global_position.y, GroundUtil.get_ground_height_at_position(camera.global_position) + 0.15)


func _on_player_spawned():
	var body = preload('res://assets/prefabs/dead-operator/dead_operator.tscn').instantiate()
	get_parent().add_child(body)
	body.global_position = global_position
	body.global_rotation = global_rotation
	body.update_position()
	queue_free()
