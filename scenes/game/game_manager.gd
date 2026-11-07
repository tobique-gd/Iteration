extends Node

@export var main_menu: Control

func _ready() -> void:
	main_menu.grab_focus()
	main_menu.enter_into_game.connect(spawn_world_scene.bind())
	
func spawn_world_scene(scene: PackedScene):
	add_child(scene.instantiate())
	main_menu.queue_free()
