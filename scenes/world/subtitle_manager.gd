extends Control

const FADE_TIME : float = 0.15

@export var rich_text_label: RichTextLabel

var _fade_tween: Tween

func _ready() -> void:
	rich_text_label.bbcode_enabled = true

func show_text(raw_text: String, duration: float) -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	
	rich_text_label.text = parse_custom_text(raw_text)
	
	_fade_tween = create_tween()
	_fade_tween.tween_property(rich_text_label, "modulate:a", 1.0, FADE_TIME)
	
	await get_tree().create_timer(duration).timeout
	
	if rich_text_label.text == parse_custom_text(raw_text):
		_fade_tween = create_tween()
		_fade_tween.tween_property(rich_text_label, "modulate:a", 0.0, FADE_TIME)

func parse_custom_text(input_string: String) -> String:
	var regex = RegEx.new()
	
	regex.compile("\\[icon:([a-zA-Z0-9_]+)(?::(\\d+))?\\]")
	
	var processed_string = input_string
	var matches = regex.search_all(input_string)
	
	for i in range(matches.size() - 1, -1, -1):
		var regex_match = matches[i]
		var action_name = regex_match.get_string(1)
		var custom_size = regex_match.get_string(2)
		
		var final_size = custom_size if not custom_size.is_empty() else "32"
		
		var texture = ControllerIcons.parse_path(action_name)
		
		if texture and not texture.resource_path.is_empty():
			var img_tag = "[img=" + final_size + "]" + texture.resource_path + "[/img]"
			
			processed_string = processed_string.erase(regex_match.get_start(), regex_match.get_string().length())
			processed_string = processed_string.insert(regex_match.get_start(), img_tag)
			
	return processed_string
