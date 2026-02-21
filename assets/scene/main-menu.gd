extends Node3D


@onready var camera: Camera3D = get_node('camera-pivot/camera-3d')
@onready var ui: Control = get_node('ui')
@onready var fade: ColorRect = get_node('fade')

@onready var button_play: Button = get_node('ui/button-play')
@onready var button_settings: Button = get_node('ui/button-settings')

@onready var settings_screen: SettingsScreen = get_node('settings')

var time := 0.0


func _ready() -> void:
	settings_screen.visible = false
	_on_resize()
	get_viewport().size_changed.connect(_on_resize)
	
	button_play.pressed.connect(_on_play_clicked)
	button_settings.pressed.connect(_on_settings_clicked)
	
	settings_screen.back_requested.connect(func():
		button_play.disabled = false
		button_settings.disabled = false
		settings_screen.visible = false
	)


func _process(delta: float) -> void:
	time += delta
	camera.rotation.x = sin(time * 1.12 + PI) * 0.015
	camera.rotation.y = sin(time * 0.95 + PI / 2.0) * 0.015
	camera.rotation.z = sin(time * 1.04 + PI * 1.5) * 0.015


func _on_resize():
	var _scale = get_viewport().size.y / 900.0
	ui.scale = Vector2(_scale, _scale)


func _on_play_clicked():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameState.setup_game()
	var tween = _fade_out()
	tween.tween_callback(func():
		get_tree().change_scene_to_file('res://assets/scene/main-scene.tscn')
	)


func _on_settings_clicked():
	button_play.disabled = true
	button_settings.disabled = true
	settings_screen.visible = true


func _fade_out():
	ui.visible = false
	var tween = create_tween()
	tween.tween_property(fade, 'color', Color(0.0, 0.0, 0.0, 1.0), 1.0)
	return tween
