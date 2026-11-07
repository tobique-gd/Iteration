extends Mechanism
@export var interactable_component: InteractableComponent

var toggled = false

func _ready() -> void:
	interactable_component.interacted.connect(toggle)

func toggle():
	toggled = !toggled
	
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUAD)
	
	var target_rotation = 25.0 if toggled else -25.0
	
	t.tween_property($Node3D, "rotation_degrees:x", target_rotation, 1.5)
	
	if toggled:
		activated.emit()
	else:
		deactivated.emit()
