extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var loading_icon: TextureRect = $LoadingIcon

var loading = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if animation_player.is_playing() and animation_player.current_animation_position < 6.0:
			animation_player.seek(6.0)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	if loading:
		pass

func start_loading_game():
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
