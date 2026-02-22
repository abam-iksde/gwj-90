extends MultiMeshInstance3D


const MAP_SIZE = 512
const INSTANCE_SIZE = Constants.CHUNK_SIZE - 1

var material: ShaderMaterial


func _ready() -> void:
	@warning_ignore("integer_division")
	var map_dimension := MAP_SIZE / INSTANCE_SIZE
	multimesh.instance_count = map_dimension * map_dimension
	multimesh.visible_instance_count = multimesh.instance_count
	for x in map_dimension:
		for y in map_dimension:
			var instance_index = x * map_dimension + y
			var instance_transform := Transform3D.IDENTITY
			var instance_x = float(x) * float(INSTANCE_SIZE)
			var instance_y = float(y) * float(INSTANCE_SIZE)
			instance_transform = instance_transform.translated(Vector3(
				instance_x,
				0.0,
				instance_y
			))
			multimesh.set_instance_transform(instance_index, instance_transform)

	material = material_override.duplicate()
	material_override = material

	material.set_shader_parameter(&'dig_texture', GameState.game_data.cleared_texture)
