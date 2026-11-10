extends Control

@export var animation_player: AnimationPlayer

@onready var loading_icon: TextureRect = $LoadingIcon

@onready var world_scene_uid: String = "uid://6i2gxcwg4p5j"

@export var menu: Control
@export var credits: Control
@export var options: Control

signal enter_into_game(scene)

@export var select_btn: Button
@export var back_btn: Button

@export var master_volume: HSlider
@export var music_volume: HSlider
@export var sound_effects_volume: HSlider

@export var fps_cap: OptionButton


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	push_menu(menu)
	setup_volume_sliders()
	setup_video_settings()

func setup_video_settings():
	var max_fps = Engine.max_fps

	var fps = [
		"Unlimited",
		"30",
		"60",
		"75",
		"100",
		"120",
		"144",
		"165",
		"200",
		"240",
		"360"
	]

	fps_cap.clear()

	for option in fps:
		fps_cap.add_item(option)

	var closest_id = 0
	var closest_difference = INF

	for i in range(fps.size()):
		var fps_value = 0 if i == 0 else int(fps[i])

		var difference = abs(max_fps - fps_value) if fps_value > 0 else 0

		if difference < closest_difference:
			closest_difference = difference
			closest_id = i

	fps_cap.select(closest_id)


func _reset_menu_visibility():
	menu.visible = false
	credits.visible = false
	options.visible = false

var loading = false

var menu_stack : Array[Control]

func _on_exit_pressed() -> void:
	$Sfx/Select.play()
	get_tree().quit()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var cur_time = animation_player.current_animation_position
		if animation_player.is_playing() and animation_player.current_animation == "open_game" and cur_time < 5.5:
			animation_player.advance(5.5 - cur_time)

func start_menu_music():
	AudioManager.play_music("Amber")

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
	$Sfx/Select.play()
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
	$Sfx/Select.play()
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
	$Sfx/Back.play()


func _on_options_pressed() -> void:
	$Sfx/Select.play()
	push_menu(options)
	play_switch_animation()


func setup_volume_sliders() -> void:
	var sliders = [
		master_volume,
		music_volume,
		sound_effects_volume
	]

	for slider in sliders:
		slider.min_value = -40.0
		slider.max_value = 6.0
		slider.step = 0.01
	
	
	master_volume.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	music_volume.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sound_effects_volume.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sfx"))

func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_sound_effects_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), value)


func _on_fps_cap_item_selected(index: int) -> void:
	var cap = fps_cap.get_item_text(index)
	cap = cap if cap != "Unlimited" else "0"
	Engine.max_fps = int(cap)


func _on_vsync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)
