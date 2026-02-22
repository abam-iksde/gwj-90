extends Control


const MIN_PROGRESS = 7.7
const MAX_PROGRESS = 90.6


@onready var progress_bar: TextureProgressBar = get_node('texture-progress-bar')
@onready var icon: Node2D = get_node('sprite-2d')
@onready var animation_player: AnimationPlayer = get_node('animation-player')


func _ready() -> void:
	animation_player.play(&'beat')


func _physics_process(_delta: float) -> void:
	progress_bar.value = GameState.game_data.player_health * ((MAX_PROGRESS - MIN_PROGRESS) / Constants.PLAYER_MAX_HEALTH) + MIN_PROGRESS
	animation_player.speed_scale = lerpf(2.0, 1.0, GameState.game_data.player_health / Constants.PLAYER_MAX_HEALTH)
