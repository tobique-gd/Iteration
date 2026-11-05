extends Button

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down() -> void:
	if has_focus():
		var pressed_style = get_theme_stylebox("pressed")
		add_theme_stylebox_override("focus", pressed_style)

func _on_button_up() -> void:
	remove_theme_stylebox_override("focus")
