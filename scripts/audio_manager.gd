extends Node

var soundtracks = {
	"Amber": "uid://jg3oecwx2xi0",
	"As You Prevent Do" : "uid://4l6q7oboohyg",
	"On The Island" : "uid://bvl5kqe8xkct8"
}

const FADE_DURATION := 1.5

var players: Array[AudioStreamPlayer] = []
var active_player := 0


func _ready() -> void:
	for i in range(2):
		var player := AudioStreamPlayer.new()
		player.bus = "Music"
		player.volume_db = -80.0
		add_child(player)
		players.append(player)


func play_music(music_name: String) -> void:
	if not soundtracks.has(music_name):
		push_warning("not nown soundtrack: " + music_name)
		return

	var next_player_index := 1 - active_player

	var current_player := players[active_player]
	var next_player := players[next_player_index]

	var stream := load(soundtracks[music_name]) as AudioStream

	if next_player.stream == stream and next_player.playing:
		return

	next_player.stream = stream
	next_player.volume_db = -80.0
	next_player.play()

	var tween := create_tween().set_parallel(true)

	tween.tween_property(
		current_player,
		"volume_db",
		-80.0,
		FADE_DURATION
	)

	tween.tween_property(
		next_player,
		"volume_db",
		0.0,
		FADE_DURATION
	)

	tween.chain().tween_callback(current_player.stop)

	active_player = next_player_index
