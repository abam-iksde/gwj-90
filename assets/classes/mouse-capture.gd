class_name MouseCapture
extends Node


func _input(event: InputEvent) -> void:
	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event:
		if mouse_button_event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
	var key_event := event as InputEventKey
	if key_event:
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return
