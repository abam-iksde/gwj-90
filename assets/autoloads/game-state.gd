extends Node


signal player_died


var start_image := preload('res://assets/map/dig-default.png').get_image()
var height_map_image := preload('res://assets/map/heightmap2.png').get_image()


var game_data: GameData


func _ready() -> void:
	start_image.decompress()
	height_map_image.decompress()
	setup_game()


func setup_game() -> void:
	game_data = GameData.new(start_image)


func notify_player_died():
	if game_data.player_dead:
		return
	player_died.emit()
	game_data.player_dead = true


var scene_root: Node3D
var ui: UiContainer
var mouse_capture: MouseCapture
var plow: Plow
var environment: GameWorldEnvironment
