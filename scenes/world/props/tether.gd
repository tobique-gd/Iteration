
extends Node3D
class_name Tether

signal recall_unlocked

@export var interactable_component: InteractableComponent
@export var anchor: Marker3D
@export var particles_active: GPUParticles3D

@export var spawnpoint: Marker3D
@export var spawn_offset: Vector3:
	set(new_val):
		spawnpoint.position = new_val
		spawn_offset = new_val

@export var unlock_recall: bool = false
@export var activated = false

func _ready() -> void:
	WorldManager.register_anchor(self)
	interactable_component.interacted.connect(on_interact)

func deactivate():
	particles_active.emitting = false

func on_interact():
	$activated_sfx.play()
	activated = true
	if unlock_recall:
		recall_unlocked.emit()
		WorldManager.recall_unlocked = true

	WorldManager.activate_anchor(anchor, spawnpoint)
	particles_active.emitting = true
	
