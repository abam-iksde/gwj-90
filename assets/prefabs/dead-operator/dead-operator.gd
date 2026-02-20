extends Node3D


func _ready() -> void:
	rotation_degrees = Vector3(
		randf_range(-7.0, 7.0),
		randf_range(0.0, 360.0),
		0.0
	)
