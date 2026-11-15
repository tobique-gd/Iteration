extends RigidBody3D
class_name PowerCube

@export var rotation_speed: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var interactable_component: InteractableComponent

var on_pedestal: bool = false
var is_held: bool = false

var original_collision_layer: int
var original_collision_mask: int


func _ready() -> void:
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

	if interactable_component:
		interactable_component.interacted.connect(interact)


func _process(delta: float) -> void:
	if on_pedestal:
		rotate_x(rotation_speed.x * delta)
		rotate_y(rotation_speed.y * delta)
		rotate_z(rotation_speed.z * delta)


func interact() -> void:
	if is_held or on_pedestal:
		return

	var player := get_tree().get_first_node_in_group("player_entity") as PlayerEntity

	if player:
		player.hold_item(self)


func pick_up(holder: Node3D) -> void:
	is_held = true
	on_pedestal = false

	freeze = true
	sleeping = true

	collision_layer = 0
	collision_mask = 0

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	
	reparent(holder, false)

	position = Vector3.ZERO
	rotation = Vector3.ZERO


func place_on_pedestal(holder: Node3D) -> void:
	is_held = false
	on_pedestal = true

	freeze = true
	sleeping = true

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	reparent(holder, false)

	position = Vector3.ZERO
	rotation = Vector3.ZERO


func drop_to_ground() -> void:
	is_held = false
	on_pedestal = false

	reparent(get_tree().current_scene, true)

	freeze = false

	collision_layer = original_collision_layer
	collision_mask = original_collision_mask

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	sleeping = false
