extends Control

@export var animation_player: AnimationPlayer

@onready var loading_icon: TextureRect = $LoadingIcon

@onready var world_scene_uid: String = "uid://6i2gxcwg4p5j"

@export var menu: Control
@export var credits: Control

signal enter_into_game(scene)

@onready var select_btn: Button = $MenuVisibilityWrapper/MarginContainer/HBoxContainer/Select
@onready var back_btn: Button = $MenuVisibilityWrapper/MarginContainer/HBoxContainer/Back

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	push_menu(menu)

func _reset_menu_visibility():
	menu.visible = false
	credits.visible = false

var loading = false

var menu_stack : Array[Control]

func _on_exit_pressed() -> void:
	get_tree().quit()

func start_menu_music():
	AudioManager.play_music("As You Prevent Do")

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
			enter_into_game.emit(scene)
			

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

func push_menu(_menu: Control):
	menu_stack.append(_menu)

func pop_menu():
	menu_stack.pop_back()

func _on_start_pressed() -> void:
	animation_player.play("start_game")

func switch_menu():
	if menu_stack.size() <= 0:
		return
		
	
	if menu_stack.size() > 1:
		back_btn.visible = true
	else:
		back_btn.visible = false
	
	_reset_menu_visibility()
	var idx = menu_stack.size() - 1
	

		
	menu_stack[idx].visible = true


func _on_credits_pressed() -> void:
	push_menu(credits)
	play_switch_animation()

func play_switch_animation():
	if animation_player.is_playing():
		animation_player.seek(1.0)
	
	animation_player.play("switch_menu")

func _on_back_pressed() -> void:
	if menu_stack.size() <= 0:
		return
	
	pop_menu()
	play_switch_animation()
