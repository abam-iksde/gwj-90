extends TextureRect


@onready var button_exit: Button = get_node('button-exit')
@onready var button_sleep: Button = get_node('button-sleep')
@onready var slider_sleep_time: HSlider = get_node('sleep-slider')

@onready var slider_supply: HSlider = get_node('supply-slider')
@onready var label_fuel: Label = get_node('label-fuel')
@onready var label_food: Label = get_node('label-food')


var supply_slider_dragging := false


func on_show(_payload):
	GameState.mouse_capture.unfocus_mouse()
	update_values()


func on_hide():
	pass


func _ready() -> void:
	button_exit.pressed.connect(_on_exit_clicked)
	button_sleep.pressed.connect(_on_sleep_clicked)
	slider_supply.drag_started.connect(func(): supply_slider_dragging = true)
	slider_supply.drag_ended.connect(func(_value): supply_slider_dragging = false)


func _on_exit_clicked():
	get_tree().paused = false
	GameState.mouse_capture.focus_mouse()
	GameState.ui.hide_modal()


func _on_sleep_clicked():
	GameState.game_data.time += slider_sleep_time.value
	GameState.game_data.player_health = 100.0


func _process(_delta: float) -> void:
	if not supply_slider_dragging:
		return
	
	update_values()


func update_values():
	var food_value := roundi(slider_supply.value / 10.0 * Constants.MAX_FOOD_IN_INVENTORY)
	var fuel_value := roundf((10.0 - slider_supply.value) / 10.0 * Constants.MAX_FUEL_IN_INVENTORY)
	label_food.text = str(food_value) + ' meals'
	label_fuel.text = str(int(fuel_value)) + 'L gas'
	
	GameState.game_data.player_food = food_value
	GameState.game_data.player_fuel = fuel_value
