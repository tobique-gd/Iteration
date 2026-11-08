extends Mechanism

var powered = false
var num_of_bodies = 0
@export var pad : MeshInstance3D

var move_tween : Tween

func _on_area_3d_body_entered(_body: Node3D) -> void:
	num_of_bodies += 1
	powered = true
	activated.emit()
	if move_tween and move_tween.is_valid():
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(pad, "position:y", -0.04, 1.0)
	

func _on_area_3d_body_exited(_body: Node3D) -> void:
	num_of_bodies -= 1
	if num_of_bodies == 0:
		powered = false
		deactivated.emit()
	
	if move_tween and move_tween.is_valid():
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(pad, "position:y", 0.042, 1.0)
	
