extends Node3D

var is_open = false

@export var animation_player: AnimationPlayer
@export var mechanism_controller: MechanismController

func _ready() -> void:
	mechanism_controller.mechanism_activated.connect(open)
	mechanism_controller.mechanism_deactivated.connect(close)


func open() -> void:
	if is_open:
		return
	
	await get_tree().create_timer(0.5).timeout
	is_open = true

	animation_player.play("OpenDoor_01_Level_01")

func close() -> void:
	if not is_open:
		return
	
	await get_tree().create_timer(3.0).timeout
	
	is_open = true

	animation_player.play("CloseDoor_01_Level_01")
