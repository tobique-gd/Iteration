@tool
extends Area3D
class_name InteractableComponent

signal interacted()

@export_tool_button("Create Collision Shape", "CollisionObject3D") var create_col_btn : Callable = create_col_shape
@export_tool_button("Create Interact Prompt", "SpriteFrames") var create_interact_prompt_btn : Callable = create_interact_prompt
@export var interact_prompt_offset : Vector3

var interact_button: Sprite3D

var prompt_tween: Tween

func _ready() -> void:
	interact_button = get_node("InteractPrompt")

func create_col_shape():
	var col = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.name = "InteractCollisionShape"
	add_child(col)
	
	if Engine.is_editor_hint():
		col.owner = get_tree().edited_scene_root
	
func create_interact_prompt():
	var sprite_3d = Sprite3D.new()
	var texture = ControllerIconTexture.new()
	texture.path = "interact"
	sprite_3d.texture = texture
	sprite_3d.scale = Vector3(0.05, 0.05, 0.05)
	sprite_3d.fixed_size = true
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	add_child(sprite_3d)
	sprite_3d.name = "InteractPrompt"
	
	if Engine.is_editor_hint():
		sprite_3d.owner = get_tree().edited_scene_root

@export var interact_prompt_radius: float = 1.0

func _process(delta: float) -> void:
	if not interact_button:
		return

	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	var direction := camera.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() < 0.001:
		return

	direction = direction.normalized()

	var target_position := direction * interact_prompt_radius
	target_position.y = 0.0

	interact_button.position = interact_button.position.lerp(
		target_position,
		1.0 - exp(-8.0 * delta)
	)

	interact_button.look_at(camera.global_position, Vector3.UP)



func interact():
	interacted.emit()



func _on_area_entered(_area: Area3D) -> void:
	animate_prompt_alpha(1.0)


func _on_area_exited(_area: Area3D) -> void:
	animate_prompt_alpha(0.0)


func animate_prompt_alpha(target_alpha: float) -> void:
	if not interact_button:
		return

	if prompt_tween and prompt_tween.is_running():
		prompt_tween.kill()

	prompt_tween = create_tween()
	prompt_tween.set_trans(Tween.TRANS_SINE)
	prompt_tween.set_ease(Tween.EASE_OUT)

	prompt_tween.tween_property(
		interact_button,
		"modulate:a",
		target_alpha,
		0.2
	)
