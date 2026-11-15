extends Control

@export var tether: Tether

func _ready() -> void:
	tether.recall_unlocked.connect(on_ru)
	
func on_ru():
	AudioManager.play_music("Exploring The Crystal Caves")
	AudioManager.set_volume(-5.0)
	$AnimationPlayer.play("new_ability")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	SubtitleManager.show_text("Press [icon:record:32] to start recording actions.", 5.0)
	queue_free()
