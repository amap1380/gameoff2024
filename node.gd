extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_type():
		print_debug(event)
