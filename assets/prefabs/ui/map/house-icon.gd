extends TextureButton


@onready var icon_container: MapIconContainer = get_parent()

var spawn_position: Vector3
var spawn_rotation: float


func _ready() -> void:
	pressed.connect(_on_pressed)
	icon_container.house_selected.connect(_on_house_selected)


func _on_pressed() -> void:
	icon_container.select(self)


func _on_house_selected(house: TextureButton) -> void:
	if house == self:
		texture_normal = preload('res://assets/prefabs/ui/map/house-selected.png')
		texture_pressed = preload('res://assets/prefabs/ui/map/house-selected.png')
		texture_hover = preload('res://assets/prefabs/ui/map/house-selected.png')
		texture_focused = preload('res://assets/prefabs/ui/map/house-selected.png')
		return
	texture_normal = preload('res://assets/prefabs/ui/map/house-inactive.png')
	texture_pressed = preload('res://assets/prefabs/ui/map/house-selected.png')
	texture_hover = preload('res://assets/prefabs/ui/map/house-active.png')
	texture_focused = preload('res://assets/prefabs/ui/map/house-active.png')


func disable():
	disabled = true
	texture_normal = preload('res://assets/prefabs/ui/map/house-inactive.png')
	texture_pressed = preload('res://assets/prefabs/ui/map/house-inactive.png')
	texture_hover = preload('res://assets/prefabs/ui/map/house-inactive.png')
	texture_focused = preload('res://assets/prefabs/ui/map/house-inactive.png')
	texture_disabled = preload('res://assets/prefabs/ui/map/house-inactive.png')
