extends TextureRect


@onready var button_exit: Button = get_node('button-exit')
@onready var button_sleep: Button = get_node('button-sleep')
@onready var slider_sleep_time: HSlider = get_node('sleep-slider')

@onready var slider_supply: HSlider = get_node('supply-slider')
@onready var label_fuel: Label = get_node('label-fuel')
@onready var label_food: Label = get_node('label-food')

@onready var label_rest: Label = get_node('label-rest')

@onready var rest_confirmation = get_node('sleep-confirm')
@onready var rested_label: Label = get_node('sleep-confirm/label')
@onready var button_rested_ok: Button = get_node('sleep-confirm/button-ok')


var supply_slider_dragging := false
var sleep_slider_dragging := false


func on_show(_payload):
	get_tree().paused = true
	GameState.mouse_capture.unfocus_mouse()
	update_values()
	request_tutorial()


func on_hide():
	pass


func _ready() -> void:
	button_exit.pressed.connect(_on_exit_clicked)
	button_sleep.pressed.connect(_on_sleep_clicked)
	slider_supply.drag_started.connect(func(): supply_slider_dragging = true)
	slider_supply.drag_ended.connect(func(_value): supply_slider_dragging = false)
	slider_sleep_time.drag_started.connect(func(): sleep_slider_dragging = true)
	slider_sleep_time.drag_ended.connect(func(_value): sleep_slider_dragging = false)
	
	button_rested_ok.pressed.connect(_on_sleep_confirmed)
	rest_confirmation.visible = false


func _on_exit_clicked():
	get_tree().paused = false
	GameState.mouse_capture.focus_mouse()
	GameState.ui.hide_modal()


func _on_sleep_clicked():
	GameState.game_data.time += slider_sleep_time.value
	GameState.game_data.player_health = Constants.PLAYER_MAX_HEALTH
	
	slider_sleep_time.editable = false
	slider_supply.editable = false
	button_exit.disabled = true
	button_sleep.disabled = true
	rest_confirmation.visible = true
	
	rested_label.text = 'You rested for ' + str(int(slider_sleep_time.value)) + ' hours.\nYou are healthy.'


func _on_sleep_confirmed():
	slider_sleep_time.editable = true
	slider_supply.editable = true
	button_exit.disabled = false
	button_sleep.disabled = false
	rest_confirmation.visible = false


func _process(_delta: float) -> void:
	if not supply_slider_dragging and not sleep_slider_dragging:
		return
	
	update_values()


func update_values():
	var food_value := roundi(slider_supply.value / 10.0 * Constants.MAX_FOOD_IN_INVENTORY)
	var fuel_value := roundf((10.0 - slider_supply.value) / 10.0 * Constants.MAX_FUEL_IN_INVENTORY)
	label_food.text = str(food_value) + ' meals'
	label_fuel.text = str(int(fuel_value / 10.0)) + 'L gas'
	
	var sleep_int := int(slider_sleep_time.value)
	if sleep_int == 1:
		label_rest.text = '1 hour'
	else:
		label_rest.text = str(int(slider_sleep_time.value)) + ' hours'
	
	GameState.game_data.player_food = food_value
	GameState.game_data.player_fuel = fuel_value


func request_tutorial():
	var tween := create_tween()
	tween.tween_interval(UiContainer.SLIDE_TIME - 0.03)
	tween.tween_callback(func():
		if GameState.request_tutorial('site', false, false):
			await GameState.tutorial_hidden
			GameState.request_tutorial('site2', false, false)
	)
