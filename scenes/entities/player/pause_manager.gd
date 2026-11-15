extends Node

@export var options_container: Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()
		return


func toggle_pause() -> void:
	var tree := get_tree()

	tree.paused = not tree.paused
	options_container.visible = tree.paused

	if tree.paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
