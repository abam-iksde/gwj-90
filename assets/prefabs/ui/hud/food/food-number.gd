extends Control


@onready var label: Label = get_node('label')

var last_food = null


func _ready() -> void:
	update()


func _physics_process(_delta: float) -> void:
	update()


func update() -> void:
	if last_food == GameState.game_data.player_food:
		return
	last_food = GameState.game_data.player_food
	label.text = str(last_food)
