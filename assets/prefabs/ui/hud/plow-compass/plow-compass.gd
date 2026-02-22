extends Sprite2D


@onready var foreground: Sprite2D = get_node('foreground')


func _physics_process(_delta: float) -> void:
	if not GameState.plow or not GameState.player:
		visible = false
		return
	visible = true
	
	var camera := get_viewport().get_camera_3d()
	
	var position_difference := GameState.player.global_position - GameState.plow.global_position
	
	foreground.rotation = atan2(-position_difference.x, position_difference.z) + camera.rotation.y
