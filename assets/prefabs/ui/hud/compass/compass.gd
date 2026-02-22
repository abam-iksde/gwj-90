extends Sprite2D


@onready var foreground: Node2D = get_node('foreground')


func _physics_process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	foreground.rotation = camera.global_rotation.y
