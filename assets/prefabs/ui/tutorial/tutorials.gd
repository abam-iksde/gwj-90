extends ColorRect


@onready var container: TextureRect = get_node('texture-rect')

@onready var button_ok: Button = get_node('texture-rect/button-ok')

var unpause_at_end := false
var capture_mouse_at_end := false


func _ready() -> void:
	_on_resize()
	get_viewport().size_changed.connect(_on_resize)
	GameState.tutorial_requested.connect(_on_tutorial_requested)
	button_ok.pressed.connect(_on_button_ok_pressed)
	visible = false


func _on_resize():
	var viewport_size := Vector2(get_viewport().size)
	var _scale := viewport_size.y * 0.6 / container.size.y
	container.scale = Vector2(_scale, _scale)
	container.position = (viewport_size - container.size * container.scale) / 2.0


func _on_button_ok_pressed():
	visible = false
	if unpause_at_end:
		get_tree().paused = false
	if capture_mouse_at_end:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameState.notify_tutorial_hidden()


func _on_tutorial_requested(id: String, unpause_on_continue: bool, capture_mouse_on_continue: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	for child in get_node('texture-rect/texts').get_children():
		child.visible = false
	get_tree().paused = true
	get_node('texture-rect/texts/' + id).visible = true
	unpause_at_end = unpause_on_continue
	capture_mouse_at_end = capture_mouse_on_continue
