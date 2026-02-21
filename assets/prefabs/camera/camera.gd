extends Camera3D


func _ready() -> void:
	fov = GameSettings.PLOW_FOV


func _process(_delta: float) -> void:
	fov = GameSettings.PLOW_FOV
