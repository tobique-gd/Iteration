extends MarginContainer

var target_margin = 0.0
var current_m = 0.0

var button : Button

func _ready() -> void:
	button = get_child(0)
	button.focus_entered.connect(on_focus_entered)
	button.focus_exited.connect(on_focus_exited)
	button.mouse_entered.connect(on_focus_entered)
	button.mouse_exited.connect(on_focus_exited)

func _process(delta: float) -> void:
	current_m = lerp(current_m, target_margin, 7.0 * delta)
	add_theme_constant_override("margin_left", current_m)

func on_focus_entered() -> void:
	target_margin = 32.0

func on_focus_exited() -> void:
	target_margin = 0.0
