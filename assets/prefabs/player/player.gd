class_name Player
extends SnowCharacter


const BASE_MOVE_SPEED = 4.5
const SLOPE_MOVE_SPEED = 1.5
const JUMP_FORCE = 6.5
const GRAVITY = -20.0


@onready var camera: Camera3D = get_node('camera')


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var mouse_motion_event := event as InputEventMouseMotion
	if  mouse_motion_event:
		camera.rotation_degrees.x = clampf(
			camera.rotation_degrees.x - mouse_motion_event.relative.y * GameSettings.MOUSE_SENSITIVITY,
			-90.0, 90.0
		)
		camera.rotation_degrees.y -= mouse_motion_event.relative.x * GameSettings.MOUSE_SENSITIVITY


func _ready() -> void:
	camera.fov = GameSettings.ON_FOOT_FOV
	camera.make_current()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&'jump') and is_on_ground():
		_is_on_snow = false
		velocity.y = JUMP_FORCE
	var input := Input.get_vector(&'walk_left', &'walk_right', &'walk_forward', &'walk_backward').rotated(-camera.rotation.y)
	velocity.y += GRAVITY * delta
	var move_speed := SLOPE_MOVE_SPEED if _is_on_slope else BASE_MOVE_SPEED
	velocity.x = input.x * move_speed
	velocity.z = input.y * move_speed
	
	move_and_slide_with_snow()
