extends CharacterBody3D


const MOUSE_SENSITIVITY = 0.3

const DIRECTION_SPECIFIC_SNOW_MASK_SIZE = [ # starts with 0, every positive 45 degrees
	Vector3(1.5, 1.5, 2.52), # 0
	Vector3(1.35, 3.0, 2.3), # 45
	Vector3(1.65, 2.3, 2.55), # 90
	Vector3(1.68, 1.7, 2.55), # 135
	Vector3(1.8, 2.7, 2.55), # 180
	Vector3(1.9, 1.7, 2.55), # 225
	Vector3(1.9, 1.9, 2.8), # 270
	Vector3(1.7, 1.7, 2.75), # 315
]

const _45_DEGREES = deg_to_rad(45.0)

const RETRIGGER_ROTATION_STEP = deg_to_rad(7.0)


const DRIVE_SPEED = 4.0
const TURN_SPEED = 2.0


@onready var camera_target: Node3D = get_node('camera-target')

var integer_position_left := false
var integer_position_top := false
var last_integer_position := Vector2i.ZERO
var rotation_diff := 0.0


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
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var mouse_motion_event := event as InputEventMouseMotion
	if  mouse_motion_event:
		camera_target.rotation_degrees.x = clampf(
			camera_target.rotation_degrees.x - mouse_motion_event.relative.y * MOUSE_SENSITIVITY,
			-90.0, 90.0
		)
		camera_target.rotation_degrees.y -= mouse_motion_event.relative.x * MOUSE_SENSITIVITY


func _physics_process(delta: float) -> void:
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	var input := Input.get_vector(
		&'drive_turn_left',
		&'drive_turn_right',
		&'drive_forward',
		&'drive_backward'
	)
	
	rotation_diff += -input.x * delta * TURN_SPEED
	rotate(Vector3.UP, -input.x * delta * TURN_SPEED)
	
	var rotation_retrigger := false
	if absf(rotation_diff) > RETRIGGER_ROTATION_STEP:
		rotation_diff -= sign(rotation_diff) * RETRIGGER_ROTATION_STEP
		rotation_retrigger = true
	
	var velocity_2d = (input * Vector2(0.0, 1.0)).rotated(-rotation.y) * DRIVE_SPEED
	
	var next_position := Vector2(
		global_position.x + velocity_2d.x * delta,
		global_position.z + velocity_2d.y * delta
	)
	
	var new_integer_position_left := next_position.x < 0.5
	var new_integer_position_top := next_position.y < 0.5
	var new_integer_position := round_vector2(next_position)
	if (
		new_integer_position != last_integer_position
		or new_integer_position_left != integer_position_left
		or new_integer_position_top != integer_position_top
		or rotation_retrigger
	):
		# TODO: check if the snow is not too high
		last_integer_position = new_integer_position
		integer_position_left = new_integer_position_left
		integer_position_top = new_integer_position_top
		clear_snow()
	
	velocity = Vector3(velocity_2d.x, 0.0, velocity_2d.y)
	move_and_slide()

func clear_snow():
	while rotation.y < 0.0:
		rotation.y += 2 * PI
	while rotation.y >= 2 * PI:
		rotation.y -= 2 * PI
	
	var first_index := 0
	var rot := rotation.y
	while rot > _45_DEGREES:
		first_index += 1
		rot -= _45_DEGREES
	
	var extents_1 = DIRECTION_SPECIFIC_SNOW_MASK_SIZE[first_index]
	var extents_2 = DIRECTION_SPECIFIC_SNOW_MASK_SIZE[(first_index + 1) % len(DIRECTION_SPECIFIC_SNOW_MASK_SIZE)]
	var final_extents := Vector3(
		lerpf(extents_1.x, extents_2.x, rot / _45_DEGREES),
		lerpf(extents_1.y, extents_2.y, rot / _45_DEGREES),
		lerpf(extents_1.z, extents_2.z, rot / _45_DEGREES)
	)
	
	var vertices = [
		last_integer_position + round_vector2(Vector2(-final_extents.x, -final_extents.z).rotated(-rotation.y)),
		last_integer_position + round_vector2(Vector2(-final_extents.x * 0.5, final_extents.z / 2.0).rotated(-rotation.y)),
		last_integer_position + round_vector2(Vector2(final_extents.y * 0.5, final_extents.z / 2.0).rotated(-rotation.y)),
		last_integer_position + round_vector2(Vector2(final_extents.y, -final_extents.z).rotated(-rotation.y)),
	]
	TriangleRasterizer.draw_triangle(
		GameState.cleared_image,
		vertices[0],
		vertices[1],
		vertices[2],
		Color.WHITE,
		not integer_position_left,
		false
	)
	TriangleRasterizer.draw_triangle(
		GameState.cleared_image,
		vertices[0],
		vertices[1],
		vertices[3],
		Color.WHITE,
		not integer_position_left,
		not integer_position_top
	)
	GameState.cleared_texture.update(GameState.cleared_image)


func round_vector2(v: Vector2) -> Vector2i:
	return Vector2i(
		roundi(v.x),
		roundi(v.y)
	)
