extends Node3D

signal activated
signal deactivated

var powered = false

var num_of_bodies = 0

func _on_area_3d_body_entered(_body: Node3D) -> void:
	num_of_bodies += 1
	powered = true
	activated.emit()

func _on_area_3d_body_exited(_body: Node3D) -> void:
	num_of_bodies -= 1
	if num_of_bodies == 0:
		powered = false
		deactivated.emit()
