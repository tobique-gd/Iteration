@tool
extends Area3D

@export var use_autoload: bool = false
@export var node_to_call: NodePath
@export var on_enter_called_function_name : String = "show_text" # Výchozí název

@export var arguments: Array = []

@export var one_shot: bool = true

@export_tool_button("Create Collision Shape", "CollisionObject3D") var create_col_btn : Callable = create_col_shape

var interacted = false

func create_col_shape():
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.name = "InteractCollisionShape"
	add_child(col)
	
	if Engine.is_editor_hint():
		col.owner = get_tree().edited_scene_root

func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)

func _on_body_entered(_body):
	if interacted: return
	
	var target_node: Node = SubtitleManager if use_autoload else get_node_or_null(node_to_call)
	
	if target_node and target_node.has_method(on_enter_called_function_name):
		interacted = true
		
		if not arguments.is_empty():
			target_node.callv(on_enter_called_function_name, arguments)
		else:
			target_node.call(on_enter_called_function_name)
	
	if interacted and one_shot:
		queue_free()
