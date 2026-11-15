extends Node

var current_anchor_transform: Transform3D
var current_spawnpoint_transform: Transform3D
var has_anchor: bool = false
var recall_unlocked: bool = false
var active_anchor: Tether = null
var anchors : Array[Tether] = []

func register_anchor(anchor: Tether):
	anchors.append(anchor)


func activate_anchor(anchor: Node3D, spawnpoint: Node3D) -> void:
	current_anchor_transform = anchor.global_transform
	current_spawnpoint_transform = spawnpoint.global_transform
	has_anchor = true
	for a in anchors:
		a.deactivate()

	EchoManager.stop_iteration()
	EchoManager.clear_echoes()
	RecordingManager.clear_recordings()


func respawn_player(player: CharacterBody3D) -> void:
	if not has_anchor:
		push_warning("no anchor activated")
		return

	player.velocity = Vector3.ZERO

	var spawn_transform := current_spawnpoint_transform
	var space_state := player.get_world_3d().direct_space_state

	var ray_start := spawn_transform.origin + Vector3.UP * 2.0
	var ray_end := spawn_transform.origin + Vector3.DOWN * 10.0

	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	query.hit_from_inside = true
	query.hit_back_faces = true

	var hit := space_state.intersect_ray(query)

	if hit.is_empty():
		push_warning("No floor found below spawn point")
		player.global_transform = spawn_transform
		return

	var floor_position: Vector3 = hit.position

	spawn_transform.origin = floor_position
	player.global_transform = spawn_transform
	player.stamina = player.MAX_STAMINA
