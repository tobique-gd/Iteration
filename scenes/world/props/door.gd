extends Node3D

var is_open = false

var animation_player : AnimationPlayer
@export var mechanism_controller : MechanismController

func _ready() -> void:
	animation_player = get_node("AnimationPlayer")
	mechanism_controller.mechanism_activated.connect(open)
	mechanism_controller.mechanism_deactivated.connect(close)

func open() -> void:
	if is_open:
		return

	is_open = true
	animation_player.play("open")


func close() -> void:
	if not is_open:
		return

	is_open = false
	animation_player.play("close")
