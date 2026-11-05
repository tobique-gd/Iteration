
class_name Echo
extends PlayerEntity

signal playback_finished(echo: Echo)

enum State {
	PLAYING,
	FINISHED,
	REMOVED
}

var state: State = State.PLAYING

var recording: PlayerRecording

var current_event_index: int = 0
var current_frame_index: int = 0

var playback_time: float = 0.0

var recorded_direction: Vector3 = Vector3.ZERO
var recorded_sprinting: bool = false
var jump_event_pending: bool = false


func is_echo() -> bool:
	return true


func setup(new_recording: PlayerRecording) -> void:
	recording = new_recording
	restart_playback()


func restart_playback() -> void:
	if recording == null:
		return

	playback_time = 0.0

	current_event_index = 0
	current_frame_index = 0

	recorded_direction = Vector3.ZERO
	recorded_sprinting = false
	jump_event_pending = false

	state = State.PLAYING

	velocity = Vector3.ZERO

	global_position = recording.starting_position
	global_rotation = recording.starting_rotation


func _physics_process(delta: float) -> void:
	if state == State.REMOVED:
		return

	if state == State.PLAYING:
		if recording == null:
			finish_playback()
		else:
			playback_time = EchoManager.iteration_time
			update_playback()

			if playback_time >= recording.duration:
				finish_playback()

	super._physics_process(delta)


func update_playback() -> void:
	var frames := recording.frames

	while current_frame_index < frames.size():
		var frame := frames[current_frame_index]

		if frame.timestamp > playback_time:
			break

		recorded_direction = frame.movement_direction
		recorded_sprinting = frame.sprinting

		if frame.jump_pressed:
			jump_event_pending = true

		current_frame_index += 1


func get_movement_direction() -> Vector3:
	return recorded_direction


func get_sprint_input() -> bool:
	return recorded_sprinting


func get_jump_input() -> bool:
	if jump_event_pending:
		jump_event_pending = false
		return true

	return false


func finish_playback() -> void:
	if state != State.PLAYING:
		return

	state = State.FINISHED

	recorded_direction = Vector3.ZERO
	recorded_sprinting = false
	jump_event_pending = false

	playback_finished.emit(self)


func remove_echo() -> void:
	if state == State.REMOVED:
		return

	state = State.REMOVED
	queue_free()
