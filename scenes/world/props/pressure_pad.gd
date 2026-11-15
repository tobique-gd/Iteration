
extends Mechanism

var powered := false

@export var pad: MeshInstance3D
@export var area_3d: Area3D

var move_tween: Tween

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if powered:
		return

	powered = true
	activated.emit()

	animate_pad(-0.04)


func _on_area_3d_body_exited(_body: Node3D) -> void:
	if area_3d.get_overlapping_bodies().size() > 0:
		return

	if not powered:
		return

	powered = false
	deactivated.emit()

	animate_pad(0.042)


func animate_pad(target_y: float) -> void:
	if move_tween and move_tween.is_valid():
		move_tween.kill()

	move_tween = create_tween()
	move_tween.tween_property(
		pad,
		"position:y",
		target_y,
		1.0
	)
