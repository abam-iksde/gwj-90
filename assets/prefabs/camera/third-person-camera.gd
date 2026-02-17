class_name ThirdPersonCamera
extends Node3D


@export var ground_step := 0.5
@export var distance := 5.0

@onready var camera: Camera3D = get_node('camera')
@onready var shape_cast: ShapeCast3D = get_node('shape-cast')


func _ready() -> void:
	var parent := get_parent() as CollisionObject3D
	if parent:
		shape_cast.add_exception(parent)


func _physics_process(_delta: float) -> void:
	shape_cast.target_position.z = distance
	
	var effective_distance = get_shape_cast_collision_point()
	
	camera.position = Vector3(0.0, 0.0, effective_distance)
	camera.global_position.y = maxf(
		GroundUtil.get_ground_height_at_position(camera.global_position) + 0.3,
		camera.global_position.y
	)


func add_collision_exception(object: CollisionObject3D) -> void:
	shape_cast.add_exception(object)


func get_shape_cast_collision_point() -> float:
	if not shape_cast.is_colliding():
		return distance
	return (shape_cast.to_local(shape_cast.get_collision_point(0)) + shape_cast.get_collision_normal(0)).length()
