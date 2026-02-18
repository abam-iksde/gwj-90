class_name UiContainer
extends Control


const SLIDE_TIME = 0.45


const FIXED_SCREEN_SIZE = Vector2(1600.0, 900.0)
const FIXED_MODAL_SIZE = Vector2(1120.0, 850.0)


enum Modal {
	WIN_SCREEN
}


@onready var modals = {
	Modal.WIN_SCREEN: get_node('win-screen')
}

var visible_modal: Control = null
var sliding := false


func show_modal(modal_id: Modal, payload = null) -> void:
	var modal = modals[modal_id]
	modal.on_show(payload)
	modal.visible = true
	(modal as Node).process_mode = Node.PROCESS_MODE_ALWAYS
	visible_modal = modal
	sliding = true
	update_modal_size(modal)
	var move_tween = create_tween()
	move_tween.tween_method(slide_update.bind(modal, slide_in_ease), 0.0, 1.0, SLIDE_TIME)
	move_tween.tween_callback(func(): sliding = false)


func hide_modal() -> void:
	if not visible_modal:
		return
	visible_modal.on_hide()
	visible_modal.process_mode = Node.PROCESS_MODE_DISABLED
	var move_tween = create_tween()
	move_tween.tween_method(slide_update.bind(visible_modal, slide_out_ease), 0.0, 1.0, SLIDE_TIME)
	move_tween.tween_callback(
		func():
			sliding = false
			visible_modal = null
	)


func _enter_tree() -> void:
	get_node('/root/GameState').ui = self


func _exit_tree() -> void:
	get_node('/root/GameState').ui = null


func _ready() -> void:
	for modal in modals.values():
		modal.visible = false
	get_viewport().size_changed.connect(_on_window_resized)


func slide_update(progress_flat: float, modal: Control, easing: Callable):
	var progress: float = easing.call(progress_flat)
	var viewport_size = Vector2(get_viewport().size)
	var pos1: Vector2 = Vector2(0.0, -viewport_size.y) + (viewport_size - FIXED_MODAL_SIZE * modal.scale) / 2.0
	var pos2: Vector2 = (viewport_size - FIXED_MODAL_SIZE * modal.scale) / 2.0
	modal.position = Vector2(
		lerpf(pos1.x, pos2.x, progress),
		lerpf(pos1.y, pos2.y, progress),
	)


func slide_in_ease(progress: float) -> float:
	return sin(progress * PI / 2.0)


func slide_out_ease(progress: float) -> float:
	return 1.0 - sin(progress * PI / 2.0)


func update_modal_size(modal: Control):
	var viewport_size = Vector2(get_viewport().size)
	var modal_width = viewport_size.x * (FIXED_MODAL_SIZE.x / FIXED_SCREEN_SIZE.x)
	var modal_scale = modal_width / FIXED_MODAL_SIZE.x
	var modal_height = viewport_size.y * (FIXED_MODAL_SIZE.y / FIXED_SCREEN_SIZE.y)
	if modal_scale * FIXED_MODAL_SIZE.y > modal_height:
		modal_scale = modal_height / FIXED_MODAL_SIZE.y
	modal.scale = Vector2(modal_scale, modal_scale)
	if not sliding:
		slide_update(1.0, modal, slide_in_ease)


func _on_window_resized():
	if visible_modal:
		update_modal_size(visible_modal)
