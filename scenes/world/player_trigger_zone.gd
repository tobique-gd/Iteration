@tool
extends Area3D

@export var use_autoload: bool = false
@export var autoload_name: String = "SubtitleManager"

@export var use_body_as_args: bool = false

@export var node_to_call: NodePath
@export var on_enter_called_function_name: String = "show_text"

@export var arguments: Array = []
@export var one_shot: bool = true

@export_tool_button("Create Collision Shape", "CollisionObject3D")
var create_col_btn: Callable = create_col_shape

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


func _on_body_entered(body):
	if interacted:
		return

	var target_node: Node = null

	if use_autoload:
		target_node = get_node_or_null("/root/" + autoload_name)
	else:
		target_node = get_node_or_null(node_to_call)

	if target_node and target_node.has_method(on_enter_called_function_name):
		interacted = true

		if not arguments.is_empty():
			target_node.callv(on_enter_called_function_name, arguments)
		else:
			if use_body_as_args:
				target_node.callv(on_enter_called_function_name, [body])
			else:
				target_node.call(on_enter_called_function_name)

	if interacted and one_shot:
		queue_free()
