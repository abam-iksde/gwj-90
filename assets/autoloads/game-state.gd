extends Node


var start_image := preload('res://assets/map/dig-default.png').get_image()


var cleared_image: Image
var cleared_texture: ImageTexture


func _ready() -> void:
	start_image.decompress()
	setup_game()


func setup_game() -> void:
	cleared_image = Image.create_empty(Constants.MAP_SIZE, Constants.MAP_SIZE, false, Image.FORMAT_R8)
	cleared_image.copy_from(start_image)
	
	cleared_texture = ImageTexture.create_from_image(cleared_image)
