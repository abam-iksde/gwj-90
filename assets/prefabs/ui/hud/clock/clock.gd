extends Node2D


@onready var head: Sprite2D = get_node('head')


func _ready() -> void:
	_update()


func _process(_delta: float) -> void:
	_update()


func _update():
	head.rotation = GameState.game_data.time / 24.0 * 2.0 * PI + PI
