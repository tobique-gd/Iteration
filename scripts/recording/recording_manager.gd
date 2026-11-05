extends Node

signal recording_started
signal recording_stopped(recording: PlayerRecording)
signal recording_limit_reached

var player: CharacterBody3D
var starting_position : Vector3 = Vector3.ZERO	

@export_group("Recording Settings")
@export var sample_rate: float = 60.0
@export var max_recording_duration: float = 30.0
@export var max_recordings: int = 3

var recordings: Array[PlayerRecording] = []

var current_recording: PlayerRecording = null

var is_recording: bool = false

var recording_time: float = 0.0
var sample_timer: float = 0.0

var next_recording_id: int = 0



func set_player(new_player: CharacterBody3D) -> void:
	player = new_player

func _physics_process(delta: float) -> void:
	if not is_recording:
		return

	recording_time += delta
	sample_timer += delta

	var sample_interval := 1.0 / sample_rate

	while sample_timer >= sample_interval:
		sample_timer -= sample_interval
		record_frame()

	if recording_time >= max_recording_duration:
		stop_recording()


func start_recording() -> void:
	if is_recording:
		return

	if player == null:
		push_error("no player ref")
		return

	current_recording = PlayerRecording.new()
	current_recording.recording_id = next_recording_id
	current_recording.starting_position = player.global_position
	current_recording.starting_rotation = player.global_rotation

	next_recording_id += 1

	recording_time = 0.0
	sample_timer = 0.0

	is_recording = true
	
	record_frame()
	
	recording_started.emit()
	



func stop_recording() -> PlayerRecording:
	if not is_recording:
		return null

	record_frame()

	is_recording = false

	current_recording.duration = recording_time

	var completed_recording := current_recording
	current_recording = null

	if completed_recording.is_empty():
		return null

	if recordings.size() >= max_recordings:
		recordings.pop_front()

	recordings.append(completed_recording)

	recording_stopped.emit(completed_recording)

	return completed_recording


func record_frame() -> void:
	if player == null or current_recording == null:
		return

	var frame := PlayerFrame.new()

	frame.timestamp = recording_time
	frame.movement_direction = player.get_movement_direction()
	frame.sprinting = player.sprinting
	frame.jump_pressed = player.get_jump_input()

	current_recording.add_frame(frame)


func clear_recordings() -> void:
	recordings.clear()
	current_recording = null
	is_recording = false

	recording_time = 0.0
	sample_timer = 0.0


func get_recording_count() -> int:
	return recordings.size()


func has_recordings() -> bool:
	return not recordings.is_empty()
