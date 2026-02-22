extends Node


@onready var footsteps_obj := get_node('footsteps-obj').get_children()
@onready var footsteps := get_node('footsteps').get_children()
@onready var climb_grabs := get_node('climb').get_children()
@onready var fall_obj: AudioStreamPlayer = get_node('fall-obj')
@onready var fall: AudioStreamPlayer = get_node('fall')


func play_step_sound():
	footsteps.pick_random().play()


func play_step_sound_obj():
	footsteps_obj.pick_random().play()


func play_climb_grab():
	climb_grabs.pick_random().play()


func play_fall_obj(volume: float):
	fall_obj.volume_db = volume
	fall_obj.play()


func play_fall(volume: float):
	fall.volume_db = volume
	fall.play()
