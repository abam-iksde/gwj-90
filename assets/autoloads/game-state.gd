extends Node


var cleared_image: Image
var cleared_texture: ImageTexture


func _ready() -> void:
	cleared_image = Image.create_empty(1024, 1024, false, Image.FORMAT_R8)
	cleared_image.fill(Color())
	
	cleared_texture = ImageTexture.create_from_image(cleared_image)
