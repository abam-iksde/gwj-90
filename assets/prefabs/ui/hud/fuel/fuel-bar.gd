extends Control


const MIN_PROGRESS = 7.7
const MAX_PROGRESS = 90.6


@onready var progress_bar: TextureProgressBar = get_node('texture-progress-bar')
@onready var icon: Sprite2D = get_node('sprite-2d')


func _physics_process(_delta: float) -> void:
	progress_bar.value = GameState.game_data.player_fuel * ((MAX_PROGRESS - MIN_PROGRESS) / Constants.MAX_FUEL_IN_INVENTORY) + MIN_PROGRESS
