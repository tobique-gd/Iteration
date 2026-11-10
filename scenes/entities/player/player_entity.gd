extends CharacterBody3D
class_name PlayerEntity

const WALK_SPEED: float = 2.5
const RUN_SPEED: float = 6.5
const MAX_STAMINA: float = 150.0

enum States {
	PLAY,
	CUTSCENE
}

var STATE = States.PLAY

@export_group("Movement")
@export var snap_distance: float = 0.4
@export var fall_anim_delay: float = 0.02
@export var air_turn_rate: float = 2.5

@export var ground_acceleration: float = 70.0
@export var ground_deceleration: float = 90.0
@export var ground_turn_acceleration: float = 120.0
@export var air_acceleration: float = 5.0
@export var air_deceleration: float = 2.0
@export var air_turn_acceleration: float = 250.0
var stamina: float = MAX_STAMINA


@export_group("Jump")
@export var jump_velocity: float = 6.0
@export var double_jump_velocity: float = 6.0

@export var fall_gravity_multiplier: float = 2.0
@export var max_fall_speed: float = 40.0
@export var max_jumps: int = 1
@export var coyote_time: float = 0.05
@export var jump_buffer_time: float = 0.3

@export var low_jump_multiplier: float = 4.0

@export_group("References")
@export var mesh: Node3D
@export var cam_pivot: Node3D
@export var spring_arm: SpringArm3D
@export var ground_level: RayCast3D
@export var animation_tree: AnimationTree
@export var stamina_ui: Control
@export var cam: Camera3D
@export var interact_box: Area3D
@export var cutscene_camera_intro: Camera3D

@export_group("Rotation")
@export var rotation_speed: float = 16.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.003
@export var controller_sensitivity: float = 0.003
@export var min_camera_angle: float = -60.0
@export var max_camera_angle: float = 60.0
@export var stamina_offset_3d: Vector3 = Vector3(0.6, 1.8, 0.0)

@export_group("Stamina")
@export var stamina_drain_rate: float = 15.0
@export var stamina_regen_rate: float = 10.0

@export_group("Stamina UI")
@export var stamina_idle_delay: float = 4.0
@export var stamina_fade_duration: float = 0.6


@export_group("Audio")
@export var jump_sfx: AudioStreamPlayer3D

var stamina_last_value: float = MAX_STAMINA
var stamina_idle_timer: float = 0.0
var stamina_fade_tween: Tween

var deadzone = 0.2
var controller_look_vector := Vector2.ZERO

var speed: float = 7.0
var grounded: bool = false
var airtime: float = 0.0

var is_sacrificing: bool = false
var jump_count: int = 0
var last_direction: Vector3 = Vector3.ZERO
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var sprinting: bool = false

func _ready() -> void:
	if not is_echo():
		#if STATE == States.PLAY:
			#cam.current = true
		WorldManager.activate_anchor(self)
		RecordingManager.set_player(self)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_stamina_visibility(delta: float) -> void:
	if not is_instance_valid(stamina_ui):
		return

	var draining := stamina < stamina_last_value

	if draining:
		stamina_idle_timer = 0.0

		if stamina_fade_tween and stamina_fade_tween.is_running():
			stamina_fade_tween.kill()

		stamina_ui.modulate.a = 1.0

	else:
		stamina_idle_timer += delta

		if stamina_idle_timer >= stamina_idle_delay:
			if stamina_fade_tween == null or not stamina_fade_tween.is_running():
				stamina_fade_tween = create_tween()
				stamina_fade_tween.tween_property(
					stamina_ui,
					"modulate:a",
					0.0,
					stamina_fade_duration
				)

	stamina_last_value = stamina

func update_sprint() -> void:
	if is_echo():
		sprinting = get_sprint_input() and stamina > 0.0
		return

	if Input.is_action_just_pressed("sprint") and stamina > 0.0:
		sprinting = true

	if get_movement_direction().length_squared() < 0.001:
		sprinting = false

	if stamina <= 0.0:
		sprinting = false

func is_echo() -> bool:
	return false

func _unhandled_input(event: InputEvent) -> void:
	if STATE != States.PLAY:
		return
	
	if is_echo():
		return

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	handle_controller_look(event)
	handle_mouse_look(event)

func update_stamina(delta: float) -> void:
	var is_moving := get_movement_direction().length_squared() > 0.001

	if sprinting and is_moving:
		stamina -= stamina_drain_rate * delta
	else:
		stamina += stamina_regen_rate * delta

	stamina = clampf(stamina, 0.0, MAX_STAMINA)

	if stamina <= 0.0: sprinting = false
	
	stamina_ui.set_instance_shader_parameter("progress", stamina / MAX_STAMINA)

func finish_intro() -> void:
	STATE = States.CUTSCENE
	set_animation("idle")

	cam_pivot.global_position = global_position + Vector3.UP * 1.65

	var target_transform := cam.global_transform

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		cutscene_camera_intro,
		"global_transform",
		target_transform,
		2.0
	)

	await tween.finished

	cam.make_current()

	exit_cutscene()

func handle_recording_input() -> void:
	if is_echo():
		return

	if not Input.is_action_just_pressed("record"):
		return

	if is_sacrificing:
		return

	if RecordingManager.is_recording:
		sacrifice()
	else:
		RecordingManager.start_recording()

func sacrifice() -> void:
	if is_sacrificing:
		return

	if not RecordingManager.is_recording:
		return

	is_sacrificing = true

	var recording = RecordingManager.stop_recording()

	velocity = Vector3.ZERO
	WorldManager.respawn_player(self)

	EchoManager.begin_new_iteration(recording)

	is_sacrificing = false

func get_player_input() -> PlayerInput:
	var input := PlayerInput.new()

	input.movement_direction = get_movement_direction()
	input.sprinting = get_sprint_input()
	input.jump_pressed = get_jump_input()

	return input

func _process(delta: float) -> void:
	if not is_instance_valid(stamina_ui) or not is_instance_valid(cam):
		return
	
	var cam_right: Vector3 = cam.global_transform.basis.x
	
	cam_right.y = 0.0
	cam_right = cam_right.normalized()
	
	var target_3d_pos: Vector3 = global_position + (cam_right * stamina_offset_3d.x) + (Vector3.UP * stamina_offset_3d.y)
	
	if cam.is_position_behind(target_3d_pos):
		stamina_ui.hide()
		return
		
	var screen_pos: Vector2 = cam.unproject_position(target_3d_pos)
		
	var target_pos = screen_pos - (stamina_ui.size / 2.0)
	stamina_ui.global_position = lerp(stamina_ui.global_position, target_pos, 3.0 * delta)
	stamina_ui.show()

func handle_interact():
	if get_interact_input():
		for area in interact_box.get_overlapping_areas():
			if not area.has_method("interact"):
				return
			
			area.interact()


func enter_cutscene():
	stamina_fade_tween = create_tween()
	stamina_fade_tween.tween_property(
		stamina_ui,
		"modulate:a",
		0.0,
		stamina_fade_duration
	)
	
	STATE = States.CUTSCENE

func trigger_intro():
	set_animation("intro_cutscene")



func exit_cutscene():
	STATE = States.PLAY

func _physics_process(delta: float) -> void:
	if STATE == States.CUTSCENE:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	update_timers(delta)
	update_sprint()

	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)

	move_and_slide()

	update_grounded(delta)
	

	if grounded:
		airtime = 0.0
	else:
		airtime += delta

	update_last_direction()
	update_mesh_rotation(delta)
	handle_interact()

	if not is_echo():
		
		update_stamina(delta)
		update_stamina_visibility(delta)
		
		update_camera_position(delta)
		apply_controller_look(delta)
		handle_recording_input()
		update_animation()

func get_interact_input():
	return Input.is_action_just_pressed("interact")

func handle_controller_look(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X:
			if abs(event.axis_value) > deadzone:
				controller_look_vector.x = event.axis_value
			else:
				controller_look_vector.x = 0.0
				
		if event.axis == JOY_AXIS_RIGHT_Y:
			if abs(event.axis_value) > deadzone:
				controller_look_vector.y = event.axis_value
			else:
				controller_look_vector.y = 0.0

func apply_controller_look(delta: float) -> void:
	if not is_instance_valid(cam_pivot) or not is_instance_valid(spring_arm):
		return

	if controller_look_vector.length_squared() > 0.0:
		var rotation_speed_modifier := 1000.0
		
		cam_pivot.rotate_y(-controller_look_vector.x * controller_sensitivity * rotation_speed_modifier * delta)
		
		spring_arm.rotation.x -= controller_look_vector.y * controller_sensitivity * rotation_speed_modifier * delta
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(min_camera_angle), deg_to_rad(max_camera_angle))

	

func is_character_on_floor() -> bool:
	return grounded

func update_camera_position(delta: float) -> void:
	if not is_instance_valid(cam_pivot):
		return

	cam_pivot.global_position.x = global_position.x
	cam_pivot.global_position.y = lerp(
		cam_pivot.global_position.y,
		global_position.y + 1.65,
		12.0 * delta
	)
	cam_pivot.global_position.z = global_position.z


func update_grounded(delta: float) -> void:
	if not is_instance_valid(ground_level):
		grounded = is_on_floor()
		return
	
	if velocity.y > 0.1:
		grounded = false
		return

	ground_level.force_raycast_update()

	if ground_level.is_colliding():
		var ground_y := ground_level.get_collision_point().y
		var height := global_position.y - ground_y
		if height <= snap_distance:
			global_position.y = lerp(global_position.y, ground_y, 48.0 * delta)
			velocity.y = 0.0
			grounded = true
			return

	grounded = false

func update_timers(delta: float) -> void:
	if is_character_on_floor():
		coyote_timer = coyote_time
		jump_count = 0
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if get_jump_input():
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

func handle_gravity(delta: float) -> void:
	if is_character_on_floor():
		return

	var gravity := get_gravity() * 1.2

	if velocity.y < 0.0:
		gravity *= fall_gravity_multiplier

	velocity += gravity * delta
	velocity.y = maxf(velocity.y, -max_fall_speed)

func handle_jump() -> void:
	if jump_buffer_timer <= 0.0:
		return

	var on_ground_or_coyote := coyote_timer > 0.0

	if on_ground_or_coyote:
		velocity.y = jump_velocity
		
		jump_count = 1
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		
		if sprinting:
			stamina -= 10.0
	
	if not is_echo():
		jump_sfx.play()
	

func handle_movement(delta: float) -> void:
	speed = RUN_SPEED if sprinting else WALK_SPEED

	var direction := get_movement_direction()

	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	var on_floor := is_character_on_floor()
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)

	if direction.length_squared() > 0.001:
		if on_floor:
			var accel := ground_acceleration

			if horizontal.dot(direction) < 0.0: accel = ground_turn_acceleration

			horizontal = horizontal.move_toward(direction * speed,accel * delta)
		else:
			horizontal = apply_air_control(horizontal, direction, delta)
	else:
		var decel := ground_deceleration if on_floor else air_deceleration

		horizontal = horizontal.move_toward(
			Vector3.ZERO,
			decel * delta
		)

	velocity.x = horizontal.x
	velocity.z = horizontal.z

func update_last_direction() -> void:
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)

	if horizontal_velocity.length_squared() > 0.01:
		last_direction = horizontal_velocity.normalized()

func update_mesh_rotation(delta: float) -> void:
	if not is_instance_valid(mesh):
		return

	if last_direction.length_squared() < 0.001:
		return

	var target_rotation := atan2(last_direction.x, last_direction.z) + PI
	
	var rotation_ground_bias = 1.0 if is_character_on_floor() else 2.0
	
	mesh.rotation.y = lerp_angle(
		mesh.rotation.y,
		target_rotation,
		1.0 - exp(-rotation_speed * rotation_ground_bias * delta)
	)

func handle_mouse_look(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if not is_instance_valid(cam_pivot) or not is_instance_valid(spring_arm):
		return

	cam_pivot.rotate_y(-event.relative.x * mouse_sensitivity)

	spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(min_camera_angle), deg_to_rad(max_camera_angle))

func apply_air_control(horizontal: Vector3, direction: Vector3, delta: float) -> Vector3:
	var current_speed := horizontal.length()

	if current_speed < 0.1:
		return horizontal.move_toward(direction * WALK_SPEED, air_acceleration * delta)

	var current_dir := horizontal / current_speed
	var angle := current_dir.signed_angle_to(direction, Vector3.UP)
	var max_step := air_turn_rate * delta
	var new_dir := current_dir.rotated(Vector3.UP, clampf(angle, -max_step, max_step))

	return new_dir * current_speed

func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("left", "right", "up", "down")

	var forward := -cam_pivot.global_basis.z
	var right := cam_pivot.global_basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var direction := right * input_dir.x - forward * input_dir.y

	return direction.normalized() if direction.length_squared() > 1.0 else direction

func update_animation() -> void:
	if not is_instance_valid(animation_tree):
		return

	if not grounded and airtime >= fall_anim_delay:
		set_animation("fall")
		return

	var direction := get_movement_direction()

	if direction.length_squared() < 0.001:
		set_animation("idle")
	else:
		set_animation("run" if velocity.length() > WALK_SPEED + 1.0 else "walk")

func get_sprint_input() -> bool:
	return Input.is_action_pressed("sprint")

func set_animation(state: String) -> void:
	if not is_instance_valid(animation_tree):
		return

	animation_tree.set(
		"parameters/current_state/transition_request",
		state
	)

func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")
