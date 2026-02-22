extends Control


const MIN_PROGRESS = 7.7
const MAX_PROGRESS = 92.3


@onready var progress_bar: TextureProgressBar = get_node('texture-progress-bar')
@onready var icon: Sprite2D = get_node('sprite-2d')


func _ready() -> void:
	update()


func _physics_process(_delta: float) -> void:
	update()


func update():
	if not GameState.plow or not GameState.plow.player_in:
		visible = false
		return
	visible = true
	progress_bar.value = GameState.plow.fuel * ((MAX_PROGRESS - MIN_PROGRESS) / Constants.MAX_FUEL_IN_PLOW) + MIN_PROGRESS
