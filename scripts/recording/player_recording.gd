class_name PlayerRecording
extends Resource

@export var recording_id: int = -1
@export var duration: float = 0.0

@export var frames: Array[PlayerFrame] = []
@export var events: Array[RecordedEvent] = []

@export var starting_position: Vector3 = Vector3.ZERO
@export var starting_rotation: Vector3 = Vector3.ZERO

func add_frame(frame: PlayerFrame) -> void:
	frames.append(frame)
	duration = frame.timestamp


func add_event(event: RecordedEvent) -> void:
	events.append(event)


func is_empty() -> bool:
	return frames.is_empty()
