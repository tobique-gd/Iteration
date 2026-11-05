
extends Node

const MAX_ECHOES: int = 3

const ECHO_SCENE: PackedScene = preload(
    "res://scenes/entities/echo/echo.tscn"
)

var echoes: Array[Echo] = []

var iteration_time: float = 0.0
var iteration_running: bool = false


func _physics_process(delta: float) -> void:
	if iteration_running:
		iteration_time += delta


func spawn_echo(recording: PlayerRecording) -> void:
	if recording == null or recording.frames.is_empty():
		return

	clean_invalid_echoes()

	if echoes.size() >= MAX_ECHOES:
		delete_oldest_echo()

	var echo := ECHO_SCENE.instantiate() as Echo

	get_tree().current_scene.add_child(echo)

	echo.setup(recording)

	echoes.append(echo)


func begin_new_iteration(new_recording: PlayerRecording) -> void:
	iteration_running = false
	iteration_time = 0.0

	clean_invalid_echoes()

	for echo in echoes:
		echo.restart_playback()

	if new_recording != null:
		spawn_echo(new_recording)

	iteration_time = 0.0
	iteration_running = true



func stop_iteration() -> void:
	iteration_running = false


func clean_invalid_echoes() -> void:
	echoes = echoes.filter(
		func(echo):
			return is_instance_valid(echo)
	)


func delete_echo(echo: Echo) -> void:
	if not is_instance_valid(echo):
		return

	echoes.erase(echo)
	echo.remove_echo()


func delete_latest_echo() -> void:
	clean_invalid_echoes()

	if echoes.is_empty():
		return

	delete_echo(echoes.back())


func delete_oldest_echo() -> void:
	clean_invalid_echoes()

	if echoes.is_empty():
		return

	delete_echo(echoes.front())


func clear_echoes() -> void:
	for echo in echoes:
		if is_instance_valid(echo):
			echo.remove_echo()

	echoes.clear()


func get_echo_count() -> int:
	clean_invalid_echoes()
	return echoes.size()
