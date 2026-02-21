extends TextureRect


@onready var button_close: Button = get_node('button-close')
@onready var button_respawn: Button = get_node('button-respawn')
@onready var icon_container: MapIconContainer = get_node('icons')
@onready var death_info_label: Label = get_node('death-info-label')


func _ready() -> void:
	button_close.pressed.connect(_on_exit_clicked)
	button_respawn.pressed.connect(_on_player_spawn_clicked)


func on_show(payload):
	var show_respawn_options = payload[&'show_respawn_options']
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	button_respawn.disabled = true
	if show_respawn_options:
		button_close.visible = false
		button_respawn.visible = true
		death_info_label.visible = true
	else:
		button_close.visible = true
		button_respawn.visible = false
		death_info_label.visible = false
	for child in icon_container.get_children():
		child.queue_free()
	for house in GameState.game_data.houses:
		var icon := preload('res://assets/prefabs/ui/map/house-icon.tscn').instantiate()
		icon_container.add_child(icon)
		icon.position = Vector2(
			house.global_position.x / float(Constants.MAP_SIZE) * 750.0 - icon.size.x / 2,
			house.global_position.z / float(Constants.MAP_SIZE) * 750.0 - icon.size.y / 2
		)
		icon.spawn_position = house.to_global(Vector3(0.0, 0.0, 1.0))
		icon.spawn_rotation = house.global_rotation.y - PI
		if not show_respawn_options:
			icon.disable()


func on_hide():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_exit_clicked():
	GameState.ui.hide_modal()
	get_tree().paused = false


func _on_player_spawn_clicked():
	var player := preload('res://assets/prefabs/player/player.tscn').instantiate()
	GameState.scene_root.add_child(player)
	player.global_position = icon_container.selected_house.spawn_position
	player.camera.global_rotation.y = icon_container.selected_house.spawn_rotation
	GameState.game_data.player_dead = false
	GameState.game_data.player_health = Constants.PLAYER_MAX_HEALTH
	GameState.notify_player_spawned()
	GameState.ui.hide_modal()
	GameState.ui.show_modal(UiContainer.Modal.INTERIOR)
	get_tree().paused = true
