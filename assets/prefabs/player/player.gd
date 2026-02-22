class_name Player
extends SnowCharacter


const BASE_MOVE_SPEED = 4.5
const SLOPE_MOVE_SPEED = 1.5
const SLOPE_MIN_MOVE_SPEED = 0.2
const JUMP_FORCE = 6.5
const GRAVITY = -20.0


@onready var camera: Camera3D = get_node('camera')
@onready var interact_raycast: RayCast3D = get_node('camera/ray-cast')


var step_tween: Tween = null


func _enter_tree() -> void:
	GameState.player = self


func _exit_tree() -> void:
	GameState.player = null
	if GameState.interaction_label:
		GameState.interaction_label.visible = false


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
	camera.make_current()
	interact_raycast.add_exception(self)
	
	GameState.player_died.connect(_on_death)


func _physics_process(delta: float) -> void:
	handle_interact()
	if Input.is_action_just_pressed(&'jump') and is_on_ground():
		_is_on_snow = false
		velocity.y = JUMP_FORCE
	var input := Input.get_vector(&'walk_left', &'walk_right', &'walk_forward', &'walk_backward').rotated(-camera.rotation.y)
	if input.length_squared() > 0.0:
		_start_walk_sound()
	else:
		if step_tween:
			step_tween.kill()
			step_tween = null
	velocity.y += GRAVITY * delta
	var move_speed := maxf(lerpf(SLOPE_MOVE_SPEED, SLOPE_MIN_MOVE_SPEED, (_ground_elevation - 1.7) / 4.3), SLOPE_MIN_MOVE_SPEED) if _is_on_slope else BASE_MOVE_SPEED
	velocity.x = input.x * move_speed
	velocity.z = input.y * move_speed
	
	move_and_slide_with_snow()
	if _fallen_high:
		var fall_volume := minf((-_fall_velocity / 4.0 - 15.0), 0.0)
		if _is_on_snow:
			Sounds.play_fall(fall_volume)
		else:
			Sounds.play_fall_obj(fall_volume)
		if _fall_velocity < -16.0:
			Sounds.play_grunt()
			GameState.game_data.player_health += (_fall_velocity + 16.0) * 4.0


func handle_interact():
	if not interact_raycast.is_colliding():
		GameState.interaction_label.visible = false
		return
	var interactable := interact_raycast.get_collider() as Interactable
	if not interactable:
		GameState.interaction_label.visible = false
		return
	GameState.interaction_label.visible = true
	GameState.interaction_label.text = '[F] ' + interactable.get_action_name()
	if Input.is_action_just_pressed(&'interact'):
		interactable.interact()


func _on_death():
	var dying = preload('res://assets/prefabs/player/dying-player.tscn').instantiate()
	get_parent().add_child(dying)
	dying.global_position = global_position
	dying.rotation.y = camera.rotation.y
	dying.camera.rotation.x = camera.rotation.x
	dying.camera.rotation.z = camera.rotation.z
	dying.camera.make_current()
	dying.play()
	queue_free()


func _start_walk_sound():
	if step_tween and step_tween.is_running():
		return
	_setup_walk_sound_tween()


func _setup_walk_sound_tween():
	step_tween = create_tween()
	step_tween.tween_interval(1.0 if _is_on_slope else 0.5)
	step_tween.tween_callback(func():
		if not is_on_ground():
			return
		if _is_on_slope:
			Sounds.play_climb_grab()
		else:
			if _is_on_snow:
				Sounds.play_step_sound()
			else:
				Sounds.play_step_sound_obj()
		_setup_walk_sound_tween()
	)
