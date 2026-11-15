extends Node3D

@export var mechanism_controller: MechanismController

var tween: Tween

func _ready() -> void:
	position.y = -25.0
	mechanism_controller.mechanism_activated.connect(up)
	mechanism_controller.mechanism_deactivated.connect(down)


func up() -> void:
	tween = create_tween()
	tween.tween_property(self, "position:y", 0.0, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func down() -> void:
	tween = create_tween()
	tween.tween_property(self, "position:y", -25.0, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
