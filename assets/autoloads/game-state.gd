extends Node


signal player_died
signal player_spawned
signal tutorial_requested(id: String, unpause_on_continue: bool, capture_mouse_on_continue: bool)
signal tutorial_hidden


var start_image := preload('res://assets/map/dig-default.png').get_image()
var height_map_image := preload('res://assets/map/target.png').get_image()


var game_data: GameData


func _ready() -> void:
	start_image.decompress()
	height_map_image.decompress()


func setup_game(enable_tutorial: bool) -> void:
	game_data = GameData.new(start_image)
	
	game_data.tutorials_enabled = enable_tutorial
	game_data.shown_tutorials = []


func notify_player_died():
	if game_data.player_dead:
		return
	player_died.emit()
	game_data.player_dead = true


func notify_player_spawned():
	player_spawned.emit()


func request_tutorial(id: String, unpause_on_continue = true, capture_mouse_on_continue = true) -> bool:
	if not game_data.tutorials_enabled:
		return false
	if id in game_data.shown_tutorials:
		return false
	game_data.shown_tutorials.append(id)
	tutorial_requested.emit(id, unpause_on_continue, capture_mouse_on_continue)
	return true


func notify_tutorial_hidden():
	tutorial_hidden.emit()


var scene_root: Node3D
var ui: UiContainer
var mouse_capture: MouseCapture
var plow: Plow
var environment: GameWorldEnvironment
var player: Player
var interaction_label: InteractionLabel
