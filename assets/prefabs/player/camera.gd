extends Camera3D


func _ready() -> void:
	fov = GameSettings.ON_FOOT_FOV


func _process(_delta: float) -> void:
	fov = GameSettings.ON_FOOT_FOV
