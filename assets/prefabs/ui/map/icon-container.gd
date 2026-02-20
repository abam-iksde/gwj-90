class_name MapIconContainer
extends Control


@onready var button_respawn: Button = get_node('../button-respawn')


signal house_selected(house: TextureButton)


var selected_house: TextureButton


func select(house: TextureButton):
	selected_house = house
	house_selected.emit(house)
	button_respawn.disabled = false
