extends Node3D

@export var mechanism_controller: MechanismController

@export var open_y: float = 16.7
@export var closed_y: float = 0.0
@export var tween_duration: float = 3.0

var door_tween: Tween
var is_open: bool = false


func _ready() -> void:
	mechanism_controller.mechanism_activated.connect(open_door)
	mechanism_controller.mechanism_deactivated.connect(close_door)


func open_door() -> void:
	if is_open:
		return

	is_open = true

	if door_tween and door_tween.is_running():
		door_tween.kill()

	door_tween = create_tween()
	door_tween.set_trans(Tween.TRANS_SINE)
	door_tween.set_ease(Tween.EASE_IN_OUT)

	door_tween.tween_property(self, "position:y", open_y, tween_duration)


func close_door() -> void:
	if not is_open:
		return

	is_open = false

	if door_tween and door_tween.is_running():
		door_tween.kill()

	door_tween = create_tween()
	door_tween.set_trans(Tween.TRANS_SINE)
	door_tween.set_ease(Tween.EASE_IN_OUT)

	door_tween.tween_property(self, "position:y", closed_y, tween_duration)
