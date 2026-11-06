extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var loading_icon: TextureRect = $LoadingIcon

@onready var world_scene_uid: String = "uid://l4oj16gupt4m"

var loading = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if animation_player.is_playing() and animation_player.current_animation_position < 6.0:
			animation_player.seek(6.0)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	if loading:
		var status = ResourceLoader.load_threaded_get_status(world_scene_uid)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			loading = false
			
			var tween = create_tween()

			tween.tween_property(loading_icon, "modulate:a", 0.0, 0.5)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN_OUT)
			
			await tween.finished
			
			var scene = ResourceLoader.load_threaded_get(world_scene_uid)
			get_tree().change_scene_to_packed(scene)

func start_loading_game():
	ResourceLoader.load_threaded_request(world_scene_uid)
	
	loading = true
	_start_smooth_rotation()
	
	

func _start_smooth_rotation():

	var tween = create_tween().set_loops()

	tween.tween_property(loading_icon, "rotation", loading_icon.rotation + deg_to_rad(45), 0.2)\
		.as_relative()\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_interval(1.0)

func _on_start_pressed() -> void:
	animation_player.play("start_game")
