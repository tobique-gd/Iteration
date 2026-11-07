
extends Node
class_name MechanismController

signal mechanism_activated
signal mechanism_deactivated

@export_group("Inputs")
@export var inputs: Array[Mechanism] = []

@export_enum("All", "Any", "Minimum") var input_mode: int = 0
@export_range(1, 20) var minimum_inputs: int = 2

@export_group("Behavior")
@export var inverted: bool = false
@export var one_shot: bool = false
@export var latch: bool = false

@export_group("Timing")
@export_range(0.0, 10.0) var activation_delay: float = 0.0
@export_range(0.0, 10.0) var deactivation_delay: float = 0.0

var input_states: Dictionary = {}

var is_active: bool = false
var has_activated: bool = false

var activation_timer: Timer
var deactivation_timer: Timer


func _ready() -> void:
	activation_timer = create_timer(activation_delay, _on_activation_timeout)
	deactivation_timer = create_timer(deactivation_delay, _on_deactivation_timeout)

	for puzzle_input in inputs:
		if not is_instance_valid(puzzle_input):
			continue

		input_states[puzzle_input] = false

		if puzzle_input.has_signal("activated"):
			puzzle_input.activated.connect(_on_input_activated.bind(puzzle_input))

		if puzzle_input.has_signal("deactivated"):
			puzzle_input.deactivated.connect(_on_input_deactivated.bind(puzzle_input))


func create_timer(wait_time: float, callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = maxf(wait_time, 0.001)
	add_child(timer)
	timer.timeout.connect(callback)
	return timer


func _on_input_activated(puzzle_input: Node) -> void:
	if not input_states.has(puzzle_input):
		return

	input_states[puzzle_input] = true
	update_mechanism()


func _on_input_deactivated(puzzle_input: Node) -> void:
	if not input_states.has(puzzle_input):
		return

	input_states[puzzle_input] = false
	update_mechanism()


func update_mechanism() -> void:
	if input_states.is_empty():
		return

	if one_shot and has_activated:
		return

	var active_count := 0

	for value in input_states.values():
		if value:
			active_count += 1

	var should_activate := false

	match input_mode:
		0:
			should_activate = active_count == input_states.size()

		1:
			should_activate = active_count > 0

		2:
			should_activate = active_count >= minimum_inputs

	if inverted:
		should_activate = not should_activate

	if should_activate == is_active:
		return

	if should_activate:
		deactivation_timer.stop()

		if activation_delay <= 0.0:
			activate_mechanism()
		else:
			if not activation_timer.time_left > 0.0:
				activation_timer.start(activation_delay)

	else:
		activation_timer.stop()

		if latch and is_active:
			return

		if deactivation_delay <= 0.0:
			deactivate_mechanism()
		else:
			if not deactivation_timer.time_left > 0.0:
				deactivation_timer.start(deactivation_delay)


func _on_activation_timeout() -> void:
	update_mechanism()


func _on_deactivation_timeout() -> void:
	update_mechanism()


func activate_mechanism() -> void:
	if is_active:
		return

	is_active = true
	has_activated = true

	mechanism_activated.emit()


func deactivate_mechanism() -> void:
	if not is_active:
		return

	if latch or one_shot:
		return

	is_active = false

	mechanism_deactivated.emit()


func reset_mechanism() -> void:
	activation_timer.stop()
	deactivation_timer.stop()

	is_active = false
	has_activated = false

	update_mechanism()
