extends Node3D

var is_open = false

@export var animation_player: AnimationPlayer
@export var mechanism_controller: MechanismController
@export var door_pieces: Array[MeshInstance3D]


func _ready() -> void:
	mechanism_controller.mechanism_activated.connect(open)


func open() -> void:
	if is_open:
		return

	is_open = true

	await get_tree().create_timer(0.75).timeout

	var tween = create_tween().set_parallel(true)

	for p in door_pieces:
		tween.tween_method(
			func(value: float):
				p.set_instance_shader_parameter("emmision_strength", value),
			0.0,
			5.0,
			3.0
		)

	await tween.finished

	animation_player.play("Door_03_Open")
