extends Node3D

@export var intro_level_animation_player: AnimationPlayer
@export var cutscenes: AnimationPlayer

func show_movement_tutorial_text():
	SubtitleManager.show_text("Use [icon:up:32][icon:left:32][icon:down:32][icon:right:32] to move. Press [icon:sprint:48] to toggle sprint.", 8.0)

func play_door_close_animation():
	intro_level_animation_player.play("DoorOpen")
