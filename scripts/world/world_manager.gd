extends Node

var current_anchor_transform: Transform3D
var has_anchor: bool = false


func activate_anchor(anchor: Node3D) -> void:
	current_anchor_transform = anchor.global_transform
	has_anchor = true

	EchoManager.stop_iteration()
	EchoManager.clear_echoes()
	RecordingManager.clear_recordings()


func respawn_player(player: CharacterBody3D) -> void:
	if not has_anchor:
		push_warning("no anchor activated")
		return

	player.velocity = Vector3.ZERO
	player.global_transform = current_anchor_transform
