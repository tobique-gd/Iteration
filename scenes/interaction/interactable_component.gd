@tool
extends Area3D
class_name InteractableComponent

signal interacted

@export_tool_button("Create Collision Shape", "CollisionObject3D") var create_col_btn : Callable = create_col_shape
@export_tool_button("Create Interact Prompt", "SpriteFrames") var create_interact_prompt_btn : Callable = create_interact_prompt
@export var interact_prompt_offset : Vector3

func create_col_shape():
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.name = "InteractCollisionShape"
	add_child(col)
	
	if Engine.is_editor_hint():
		col.owner = get_tree().edited_scene_root
	
func create_interact_prompt():
	pass

func interact():
	interacted.emit()
