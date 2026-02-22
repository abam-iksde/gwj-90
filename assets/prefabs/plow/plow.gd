class_name Plow
extends CharacterBody3D


const DIRECTION_SPECIFIC_SNOW_MASK_SIZE = [ # starts with 0, every positive 45 degrees
	Vector3(1.55, 1.55, 2.68), # 0
	Vector3(1.5, 2.0, 2.76), # 45
	Vector3(1.5, 2.3, 2.68), # 90
	Vector3(1.8, 1.8, 2.55), # 135
	Vector3(1.48, 2.5, 2.55), # 180
	Vector3(1.8, 1.8, 2.55), # 225
	Vector3(1.8, 1.9, 2.8), # 270
	Vector3(1.7, 1.7, 2.75), # 315
]

const _45_DEGREES = deg_to_rad(45.0)

const RETRIGGER_ROTATION_STEP = deg_to_rad(7.0)

const MAX_SNOW_HEIGHT = 2.1
const MAX_SNOW_HEIGHT_BACK = 0.7 # <- makes it easy to get stuck in the snow, not sure how to address that for now

const DRIVE_SPEED = 4.0
const DRIVE_SPEED_BACK = 2.5
const TURN_SPEED = 2.0

const CAMERA_MIN_ANGLE = -90.0
const CAMERA_MAX_ANGLE = 30.0


@onready var camera_target: Node3D = get_node('third-person-camera')
@onready var camera: Camera3D = get_node('third-person-camera/camera')
@onready var player_exit: Node3D = get_node('player-exit')

@onready var snow_particle_emitters = [
	get_node('snow-particles'),
	get_node('snow-particles2')
]

var last_integer_position := Vector2i.ZERO
var rotation_diff := 0.0

var player_in := false:
	set(value):
		player_in = value
		GameState.request_tutorial('plow')
	get():
		return player_in

var fuel := Constants.START_FUEL_IN_PLOW

var snow_particle_stop_tween: Tween = null


func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED or not player_in:
		return
	var mouse_motion_event := event as InputEventMouseMotion
	if mouse_motion_event:
		camera_target.rotation_degrees.x = clampf(
			camera_target.rotation_degrees.x - mouse_motion_event.relative.y * GameSettings.MOUSE_SENSITIVITY,
			CAMERA_MIN_ANGLE, CAMERA_MAX_ANGLE
		)
		camera_target.rotation_degrees.y -= mouse_motion_event.relative.x * GameSettings.MOUSE_SENSITIVITY


func _ready() -> void:
	camera.fov = GameSettings.PLOW_FOV
	
	GameState.plow = self
	GameState.player_died.connect(_on_death)


func _physics_process(delta: float) -> void:
	if not player_in:
		return
	
	if Input.is_action_just_pressed(&'plow_enter_exit'):
		var player := preload('res://assets/prefabs/player/player.tscn').instantiate() as Player
		get_parent().add_child(player)
		player.global_position = player_exit.global_position
		player.camera.rotation = camera_target.global_rotation
		player_in = false
	
	if fuel <= 0.0:
		GameState.request_tutorial('no_fuel')
		return
	
	fuel -= delta * Constants.PLOW_IDLE_FUEL_COST
	
	var input := Input.get_vector(
		&'drive_turn_left',
		&'drive_turn_right',
		&'drive_forward',
		&'drive_backward'
	)
	
	if input.y == 0.0:
		update_fuel_bounds()
		return
	
	if input.y < 0.0:
		fuel -= Constants.PLOW_DRIVE_FUEL_COST * delta * absf(input.y)
	else:
		fuel -= Constants.PLOW_DRIVE_FUEL_COST * delta * absf(input.y) * (DRIVE_SPEED_BACK / DRIVE_SPEED)
	
	update_fuel_bounds()
	
	rotation_diff += -input.x * delta * TURN_SPEED
	rotate(Vector3.UP, -input.x * delta * TURN_SPEED)
	
	var rotation_retrigger := false
	if absf(rotation_diff) > RETRIGGER_ROTATION_STEP:
		rotation_diff -= sign(rotation_diff) * RETRIGGER_ROTATION_STEP
		rotation_retrigger = true
	
	var velocity_2d = (input * Vector2(0.0, 1.0)).rotated(-rotation.y) * (DRIVE_SPEED if input.y < 0.0 else DRIVE_SPEED_BACK)
	
	var next_position := Vector2(
		global_position.x + velocity_2d.x * delta,
		global_position.z + velocity_2d.y * delta
	)
	
	var new_integer_position := round_vector2(next_position - Vector2(0.25, 0.25))
	if (
		new_integer_position != last_integer_position
		or rotation_retrigger
	):
		if not clear_snow(input.y < 0.0, new_integer_position):
			GameState.request_tutorial('tall_snow')
			return
		last_integer_position = new_integer_position
	
	velocity = Vector3(velocity_2d.x, 0.0, velocity_2d.y)
	move_and_slide()


func clear_snow(front: bool, new_position: Vector2i) -> bool:
	while rotation.y < 0.0:
		rotation.y += 2 * PI
	while rotation.y >= 2 * PI:
		rotation.y -= 2 * PI
	
	var first_index := 0
	var rot := rotation.y + (0.0 if front else PI)
	while rot > 2 * PI:
		rot -= 2 * PI
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
		new_position + round_vector2((Vector2(-final_extents.x, -final_extents.z) * (1.0 if front else -1.0)).rotated(-rotation.y)),
		new_position + round_vector2((Vector2(-final_extents.x * 0.5, final_extents.z / 2.0) * (1.0 if front else -1.0)).rotated(-rotation.y)),
		new_position + round_vector2((Vector2(final_extents.y * 0.5, final_extents.z / 2.0) * (1.0 if front else -1.0)).rotated(-rotation.y)),
		new_position + round_vector2((Vector2(final_extents.y, -final_extents.z) * (1.0 if front else -1.0)).rotated(-rotation.y)),
	]
	var succeeded := (
		TriangleRasterizer.draw_triangle(
			GameState.game_data.cleared_image,
			vertices[0],
			vertices[1],
			vertices[2],
			Color.WHITE,
			false,
			false,
			dig_pixel_predicate if front else dig_pixel_back_predicate
		)
		and TriangleRasterizer.draw_triangle(
			GameState.game_data.cleared_image,
			vertices[0],
			vertices[1],
			vertices[3],
			Color.WHITE,
			false,
			false,
			dig_pixel_predicate if front else dig_pixel_back_predicate
		)
	)
	GameState.game_data.cleared_texture.update(GameState.game_data.cleared_image)
	
	if TriangleRasterizer.drawn_pixels:
		for emitter in snow_particle_emitters:
			emitter.emitting = true
		if snow_particle_stop_tween:
			snow_particle_stop_tween.kill()
		snow_particle_stop_tween = create_tween()
		snow_particle_stop_tween.tween_interval(0.25)
		snow_particle_stop_tween.tween_callback(stop_emitting_particles)
	TriangleRasterizer.drawn_pixels = false
	
	return succeeded


func round_vector2(v: Vector2) -> Vector2i:
	return Vector2i(
		roundi(v.x),
		roundi(v.y)
	)


func dig_pixel_predicate(x: int, y: int) -> bool:
	var map_height := GroundUtil.color_to_height(GameState.height_map_image.get_pixel(x, y))
	var height := map_height if GameState.game_data.cleared_image.get_pixel(x, y).r < 0.5 else 0.0
	return height * Constants.HEIGHT_MAP_SCALE <= MAX_SNOW_HEIGHT


func dig_pixel_back_predicate(x: int, y: int) -> bool:
	var map_height := GroundUtil.color_to_height(GameState.height_map_image.get_pixel(x, y))
	var height := (
		map_height
		if GameState.game_data.cleared_image.get_pixel(x, y).r < 0.5 else
		0.0
	)
	return height * Constants.HEIGHT_MAP_SCALE <= MAX_SNOW_HEIGHT


func update_fuel_bounds():
	fuel = maxf(fuel, 0.0)
	if GameState.game_data.player_fuel > 0.0:
		fuel += GameState.game_data.player_fuel
		GameState.game_data.player_fuel = maxf(fuel - Constants.MAX_FUEL_IN_PLOW, 0.0)
		fuel = minf(fuel, Constants.MAX_FUEL_IN_PLOW)


func _on_death():
	if not player_in:
		return
	player_in = false
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(func():
		GameState.ui.show_modal(UiContainer.Modal.MAP, { &'show_respawn_options': true })
	)


func stop_emitting_particles():
	for emitter in snow_particle_emitters:
		emitter.emitting = false
