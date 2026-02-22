extends Node


@onready var footsteps_obj := get_node('footsteps-obj').get_children()
@onready var footsteps := get_node('footsteps').get_children()
@onready var climb_grabs := get_node('climb').get_children()
@onready var fall_obj: AudioStreamPlayer = get_node('fall-obj')
@onready var fall: AudioStreamPlayer = get_node('fall')

@onready var engine := get_node('engine').get_children()
@onready var engine_idle: AudioStreamPlayer = get_node('engine/idle-loop')
@onready var engine_drive: AudioStreamPlayer = get_node('engine/drive-loop')
@onready var engine_rev: AudioStreamPlayer = get_node('engine/high-rpm')

@onready var snow_push: AudioStreamPlayer = get_node('snow-push')

@onready var grunts := get_node('grunts').get_children()

@onready var door_open: AudioStreamPlayer = get_node('door-open')
@onready var map: AudioStreamPlayer = get_node('map')

@onready var click: AudioStreamPlayer = get_node('click')

@onready var eat := get_node('eat').get_children()


func play_step_sound():
	var step = footsteps.pick_random()
	step.stop()
	step.play()


func play_step_sound_obj():
	var step = footsteps_obj.pick_random()
	step.stop()
	step.play()


func play_climb_grab():
	var _grab = climb_grabs.pick_random()
	_grab.stop()
	_grab.play()


func play_fall_obj(volume: float):
	fall_obj.stop()
	fall_obj.volume_db = volume
	fall_obj.play()


func play_fall(volume: float):
	fall.stop()
	fall.volume_db = volume
	fall.play()


func start_engine_sounds():
	for sound in engine:
		if sound.name != 'start':
			sound.volume_db = -30.0
		sound.play()


func stop_engine_sounds():
	for sound in engine:
		sound.stop()


func play_grunt():
	var _grunt = grunts.pick_random()
	_grunt.stop()
	_grunt.play()


func play_door_open():
	door_open.stop()
	door_open.play()


func play_door_close():
	door_open.stop()
	door_open.play(3.0)


func play_map():
	map.stop()
	map.play()


func play_click():
	click.stop()
	click.play()


func play_eat():
	var eat_sound = eat.pick_random()
	eat_sound.stop()
	eat_sound.play()


func _ready() -> void:
	snow_push.play()
