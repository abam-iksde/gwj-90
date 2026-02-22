class_name GameData
extends RefCounted


var cleared_image: Image
var cleared_texture: ImageTexture

var player_health := Constants.PLAYER_MAX_HEALTH
var time := 7.0

var houses := []
var player_dead := false

var player_food := 10
var player_fuel := 0.0


var tutorials_enabled := false
var shown_tutorials = []


func _init(start_image: Image):
	cleared_image = Image.create_empty(Constants.MAP_SIZE, Constants.MAP_SIZE, false, Image.FORMAT_R8)
	cleared_image.copy_from(start_image)
	
	cleared_texture = ImageTexture.create_from_image(cleared_image)
