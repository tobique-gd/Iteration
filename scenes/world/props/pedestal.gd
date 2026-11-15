extends Mechanism
class_name CubePedestal

@export var interactable_component: InteractableComponent
@export var cube_holder: Node3D

var stored_cube: PowerCube = null
@export var store_cube: bool = false


func _ready() -> void:
	interactable_component.interacted.connect(interact)
	if store_cube:
		stored_cube = find_child("PowerCube")
		stored_cube.place_on_pedestal(cube_holder)


func interact() -> void:
	var player := get_tree().get_first_node_in_group("player_entity") as PlayerEntity
	
	if player == null:
		return
	

	if player.held_item != null:
		if stored_cube != null:
			return

		var cube := player.held_item
		
		stored_cube = cube
		player.clear_held_item()
		cube.place_on_pedestal(cube_holder)
		activated.emit()
		return
	
	if stored_cube != null:
		var cube := stored_cube
		if player.hold_item(cube):
			deactivated.emit()
			stored_cube = null
