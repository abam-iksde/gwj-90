class_name SettingsScreen
extends Control


signal back_requested
signal quit_requested


const SENSITIVITY_DENOMINATION = 160.0

@onready var container: TextureRect = get_node('texture-rect')

@onready var slider_sensitivity: HSlider = get_node('texture-rect/slider-sensitivity')

@onready var label_fov_fpp: Label = get_node('texture-rect/slider-fov-player/label')
@onready var slider_fov_fpp: HSlider = get_node('texture-rect/slider-fov-player')

@onready var label_fov_tpp: Label = get_node('texture-rect/slider-fov-plow/label')
@onready var slider_fov_tpp: HSlider = get_node('texture-rect/slider-fov-plow')

@onready var button_back: Button = get_node('texture-rect/button-back')
@onready var button_quit: TextureButton = get_node('texture-rect/button-quit')

@onready var quit_confirm: TextureRect = get_node('texture-rect/quit-confirmation')
@onready var button_quit_confirm_yes: Button = get_node('texture-rect/quit-confirmation/button-yes')
@onready var button_quit_confirm_no: Button = get_node('texture-rect/quit-confirmation/button-no')

@export var with_quit := false

var dragging_fov_fpp := false
var dragging_fov_tpp := false


func _ready() -> void:
	_on_resize()
	get_viewport().size_changed.connect(_on_resize)
	
	quit_confirm.visible = false
	button_quit.visible = with_quit
	
	slider_sensitivity.value = GameSettings.MOUSE_SENSITIVITY * SENSITIVITY_DENOMINATION
	slider_fov_fpp.value = GameSettings.ON_FOOT_FOV
	slider_fov_tpp.value = GameSettings.PLOW_FOV
	
	label_fov_fpp.text = 'FOV - first person (walk): ' + str(int(GameSettings.ON_FOOT_FOV))
	label_fov_tpp.text = 'FOV - third person (drive): ' + str(int(GameSettings.PLOW_FOV))
	
	slider_fov_fpp.drag_started.connect(func(): dragging_fov_fpp = true)
	slider_fov_fpp.drag_ended.connect(func(_value):
		dragging_fov_fpp = false
		GameSettings.save_settings()
	)
	slider_fov_tpp.drag_started.connect(func(): dragging_fov_tpp = true)
	slider_fov_tpp.drag_ended.connect(func(_value):
		dragging_fov_tpp = false
		GameSettings.save_settings()
	)
	slider_sensitivity.drag_ended.connect(func(_value):
		GameSettings.MOUSE_SENSITIVITY = slider_sensitivity.value / SENSITIVITY_DENOMINATION
		GameSettings.save_settings()
	)
	
	button_back.pressed.connect(func():
		back_requested.emit()
		Sounds.play_click()
	)
	
	button_quit.pressed.connect(_on_quit_prompt)
	button_quit_confirm_no.pressed.connect(_on_quit_cancel)
	button_quit_confirm_yes.pressed.connect(_on_quit_confirm)


func _process(_delta: float) -> void:
	if dragging_fov_fpp:
		label_fov_fpp.text = 'FOV - first person (walk): ' + str(int(slider_fov_fpp.value))
		GameSettings.ON_FOOT_FOV = slider_fov_fpp.value
	if dragging_fov_tpp:
		label_fov_tpp.text = 'FOV - third person (drive): ' + str(int(slider_fov_tpp.value))
		GameSettings.PLOW_FOV = slider_fov_tpp.value


func _on_resize():
	var viewport_size := Vector2(get_viewport().size)
	var _scale := viewport_size.y * 0.6 / container.size.y
	container.scale = Vector2(_scale, _scale)
	container.position = (viewport_size - container.size * container.scale) / 2.0


func _on_quit_prompt():
	Sounds.play_click()
	quit_confirm.visible = true
	slider_sensitivity.editable = false
	slider_fov_fpp.editable = false
	slider_fov_tpp.editable = false
	button_back.disabled = true


func _on_quit_cancel():
	Sounds.play_click()
	quit_confirm.visible = false
	slider_sensitivity.editable = true
	slider_fov_fpp.editable = true
	slider_fov_tpp.editable = true
	button_back.disabled = false


func _on_quit_confirm():
	Sounds.play_click()
	button_quit_confirm_no.disabled = true
	button_quit_confirm_yes.disabled = true
	quit_requested.emit()
