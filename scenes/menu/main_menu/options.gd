extends Control

@export var master_volume: HSlider
@export var music_volume: HSlider
@export var sound_effects_volume: HSlider

@export var fps_cap: OptionButton

func _ready():
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


func _on_tab_container_tab_changed(_tab: int) -> void:
	var sfx = get_node_or_null("Sfx/Select")
	if sfx.is_inside_tree():
		sfx.play()





func _on_exit_to_main_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game_manager.tscn")
