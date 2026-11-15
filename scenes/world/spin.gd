@tool
extends MeshInstance3D

@export_group("Progress")
@export_range(0.0, 1.0) var progress := 0.0

@export_group("Rotation")
@export var rotation_speed := 0.7
@export var final_rotation_speed := 0.08

@export_group("Wobble")
@export var wobble_speed := 0.5
@export var wobble_amount := 0.12
@export var final_wobble_amount := 0.015

@export_group("Floating")
@export var float_height := 0.15
@export var float_speed := 1.5
@export var final_float_height := 0.025
@export var final_float_speed := 0.6

var start_position: Vector3
var time := 0.0


func _ready() -> void:
	start_position = Vector3(-206.571, 48.645, -295.666)
	position = start_position


func _process(delta: float) -> void:
	time += delta

	var p := smoothstep(0.0, 1.0, progress)

	var current_rotation = lerp(rotation_speed, final_rotation_speed, p)
	var current_wobble = lerp(wobble_amount, final_wobble_amount, p)
	var current_float = lerp(float_height, final_float_height, p)
	var current_float_speed = lerp(float_speed, final_float_speed, p)

	rotate_y(current_rotation * delta)
	rotate_x(sin(time * wobble_speed) * current_wobble * delta)
	rotate_z(cos(time * wobble_speed * 0.8) * current_wobble * delta)

	position.y = start_position.y + sin(time * current_float_speed) * current_float

	position.x = start_position.x + sin(time * 0.7) * current_wobble
	position.z = start_position.z + cos(time * 0.6) * current_wobble

	set_instance_shader_parameter("progress", progress)
