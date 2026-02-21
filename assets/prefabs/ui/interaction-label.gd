class_name InteractionLabel
extends Label


func _enter_tree() -> void:
	GameState.interaction_label = self


func _exit_tree() -> void:
	GameState.interaction_label = null
