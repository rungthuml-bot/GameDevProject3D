extends CharacterBody3D

## Player Controller with Movement, Sprint (Shift), Crouch (Ctrl), Jump (Spacebar), and Perspective Toggle (V).

# =========================================================
# MOVEMENT SETTINGS
# =========================================================

@export_category("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.5
@export var crouch_speed: float = 2.4
@export var acceleration: float = 22.0
@export var deceleration: float = 22.0

# Backward compatibility alias
var move_speed: float:
	get:
		return walk_speed
	set(val):
		walk_speed = val

# =========================================================
# JUMP & GRAVITY
# =========================================================

@export_category("Jump & Gravity")
@export var jump_height: float = 2.0
@export var gravity: float = 18.0
@export var fall_gravity_multiplier: float = 1.3
@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.15

# =========================================================
# CROUCH SETTINGS
# =========================================================

@export_category("Crouch")
@export var crouch_transition_speed: float = 12.0
const STANDING_HEIGHT: float = 1.869
const CROUCH_HEIGHT: float = 1.05
const STANDING_COL_Y: float = 0.935
const CROUCH_COL_Y: float = 0.525
const STANDING_GIMBAL_Y: float = 1.4
const CROUCH_GIMBAL_Y: float = 0.85
const STANDING_MESH_SCALE_Y: float = 1.0
const CROUCH_MESH_SCALE_Y: float = 0.65

# =========================================================
# CAMERA & PERSPECTIVE SETTINGS
# =========================================================

@export_category("Camera")
@export var mouse_sensitivity: float = 0.002
@export var normal_fov: float = 65.0
@export var sprint_fov: float = 73.0
@export var crouch_fov: float = 60.0

@export_category("Perspective Mode")
@export var is_first_person: bool = false
@export var perspective_transition_speed: float = 16.0

const THIRD_PERSON_CAM_POS: Vector3 = Vector3(0.0, 1.0, 4.5)
const FIRST_PERSON_CAM_POS: Vector3 = Vector3(0.0, 0.15, -0.15)

const THIRD_PERSON_MIN_PITCH: float = -45.0
const THIRD_PERSON_MAX_PITCH: float = 55.0
const FIRST_PERSON_MIN_PITCH: float = -85.0
const FIRST_PERSON_MAX_PITCH: float = 85.0

# =========================================================
# NODE REFERENCES
# =========================================================

@onready var gimbal: Node3D = $Gimbal
@onready var camera: Camera3D = $Gimbal/Camera3D
@onready var animation_player: AnimationPlayer = $Eric/AnimationPlayer
@onready var character_mesh: Node3D = $Eric
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var interaction_area: Area3D = $InteractionArea

# =========================================================
# RUNTIME STATE
# =========================================================

var is_sprinting: bool = false
var is_crouching: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var duplicate_capsule_shape: CapsuleShape3D = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	camera.fov = normal_fov
	play_animation("CharacterArmature|Idle")

	# Initialize perspective mode from persistent GameManager state
	if GameManager:
		is_first_person = GameManager.is_first_person_enabled()

	if is_first_person:
		camera.position = FIRST_PERSON_CAM_POS
		character_mesh.visible = false
	else:
		camera.position = THIRD_PERSON_CAM_POS
		character_mesh.visible = true

	if collision_shape and collision_shape.shape is CapsuleShape3D:
		duplicate_capsule_shape = collision_shape.shape.duplicate()
		collision_shape.shape = duplicate_capsule_shape

	if UIManager:
		mouse_sensitivity = UIManager.mouse_sensitivity
		if not UIManager.settings_updated.is_connected(_on_settings_updated):
			UIManager.settings_updated.connect(_on_settings_updated)

	call_deferred("set_spawn_position")


func _on_settings_updated() -> void:
	if UIManager:
		mouse_sensitivity = UIManager.mouse_sensitivity


func set_spawn_position() -> void:
	var spawn_id := GameManager.get_spawn_point()

	if spawn_id.is_empty():
		return

	var spawn_point := get_tree().current_scene.get_node_or_null(spawn_id)

	if spawn_point == null:
		print("ERROR: Spawn point not found: ", spawn_id)
		return

	global_position = spawn_point.global_position
	global_rotation = spawn_point.global_rotation

	GameManager.clear_spawn_point()


# =========================================================
# PERSPECTIVE TOGGLE (1st / 3rd Person)
# =========================================================

func toggle_perspective() -> void:
	is_first_person = not is_first_person
	if GameManager:
		GameManager.set_first_person(is_first_person)

	if is_first_person:
		character_mesh.visible = false
		if UIManager:
			UIManager.notify_info("First-Person View (V)", 1.5)
	else:
		character_mesh.visible = true
		if UIManager:
			UIManager.notify_info("Third-Person View (V)", 1.5)


# =========================================================
# INPUT
# =========================================================

func _unhandled_input(event: InputEvent) -> void:

	# =====================================================
	# MOUSE CAMERA LOOK
	# =====================================================

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		gimbal.rotate_x(-event.relative.y * mouse_sensitivity)

		var min_pitch := FIRST_PERSON_MIN_PITCH if is_first_person else THIRD_PERSON_MIN_PITCH
		var max_pitch := FIRST_PERSON_MAX_PITCH if is_first_person else THIRD_PERSON_MAX_PITCH

		gimbal.rotation.x = clamp(
			gimbal.rotation.x,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)

	# =====================================================
	# TOGGLE PERSPECTIVE (V Key)
	# =====================================================

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_V or event.physical_keycode == KEY_V:
			toggle_perspective()
	elif event.is_action_pressed("toggle_perspective"):
		toggle_perspective()

	# =====================================================
	# JUMP INPUT BUFFER (Spacebar key event)
	# =====================================================

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE:
			jump_buffer_timer = jump_buffer_time

	# =====================================================
	# ESC — Pause
	# =====================================================

	if event.is_action_pressed("ui_pause"):
		if UIManager.is_playing():
			return

	# =====================================================
	# LEFT CLICK — Recapture Mouse
	# =====================================================

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# =========================================================
# PHYSICS
# =========================================================

func _physics_process(delta: float) -> void:

	# =====================================================
	# TIMERS & INPUT POLLING
	# =====================================================

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0.0, coyote_timer - delta)

	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

	var raw_sprint := (
		Input.is_action_pressed("sprint")
		or Input.is_physical_key_pressed(KEY_SHIFT)
		or Input.is_key_pressed(KEY_SHIFT)
	)

	var raw_crouch := (
		Input.is_action_pressed("crouch")
		or Input.is_physical_key_pressed(KEY_CTRL)
		or Input.is_key_pressed(KEY_CTRL)
	)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	# =====================================================
	# CROUCH & SPRINT STATE
	# =====================================================

	if raw_crouch:
		is_crouching = true
		is_sprinting = false
	else:
		if is_crouching and _has_ceiling_above():
			is_crouching = true
		else:
			is_crouching = false

	if not is_crouching and raw_sprint and is_on_floor():
		is_sprinting = true
	else:
		if not raw_sprint or is_crouching:
			is_sprinting = false

	# =====================================================
	# TARGET SPEED
	# =====================================================

	var target_speed := walk_speed
	if is_crouching:
		target_speed = crouch_speed
	elif is_sprinting:
		target_speed = sprint_speed

	# =====================================================
	# GRAVITY
	# =====================================================

	if not is_on_floor():
		var applied_gravity := gravity
		if velocity.y < 0.0:
			applied_gravity *= fall_gravity_multiplier
		velocity.y -= applied_gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	# =====================================================
	# JUMP EXECUTION
	# =====================================================

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# =====================================================
	# HORIZONTAL MOVEMENT
	# =====================================================

	var input_2d := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var direction := (
		right * input_2d.x
		- forward * input_2d.y
	)

	var is_moving := direction.length() > 0.01

	if is_moving:
		direction = direction.normalized()
		var current_accel := acceleration if is_on_floor() else (acceleration * 0.6)
		velocity.x = move_toward(
			velocity.x,
			direction.x * target_speed,
			current_accel * delta
		)
		velocity.z = move_toward(
			velocity.z,
			direction.z * target_speed,
			current_accel * delta
		)
	else:
		var current_decel := deceleration if is_on_floor() else (deceleration * 0.4)
		velocity.x = move_toward(velocity.x, 0.0, current_decel * delta)
		velocity.z = move_toward(velocity.z, 0.0, current_decel * delta)

	# =====================================================
	# SMOOTH CROUCH TRANSITIONS (COLLISION & CAMERA)
	# =====================================================

	var target_capsule_h := CROUCH_HEIGHT if is_crouching else STANDING_HEIGHT
	var target_col_y := CROUCH_COL_Y if is_crouching else STANDING_COL_Y
	var target_gimbal_y := CROUCH_GIMBAL_Y if is_crouching else STANDING_GIMBAL_Y
	var target_mesh_scale_y := CROUCH_MESH_SCALE_Y if is_crouching else STANDING_MESH_SCALE_Y

	var target_fov := normal_fov
	if is_crouching:
		target_fov = crouch_fov
	elif is_sprinting and is_moving:
		target_fov = sprint_fov

	if duplicate_capsule_shape != null:
		duplicate_capsule_shape.height = lerp(
			duplicate_capsule_shape.height,
			target_capsule_h,
			crouch_transition_speed * delta
		)

	collision_shape.position.y = lerp(
		collision_shape.position.y,
		target_col_y,
		crouch_transition_speed * delta
	)

	gimbal.position.y = lerp(
		gimbal.position.y,
		target_gimbal_y,
		crouch_transition_speed * delta
	)

	character_mesh.scale.y = lerp(
		character_mesh.scale.y,
		target_mesh_scale_y,
		crouch_transition_speed * delta
	)

	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)

	# =====================================================
	# PERSPECTIVE CAMERA & MESH VISIBILITY
	# =====================================================

	var target_cam_pos := FIRST_PERSON_CAM_POS if is_first_person else THIRD_PERSON_CAM_POS
	camera.position = camera.position.lerp(target_cam_pos, perspective_transition_speed * delta)

	if is_first_person:
		character_mesh.visible = false
	else:
		character_mesh.visible = true

	# =====================================================
	# ANIMATION STATE MACHINE
	# =====================================================

	if is_on_floor():
		if is_moving:
			if is_crouching:
				play_animation("CharacterArmature|Walk", 0.7)
			elif is_sprinting:
				play_animation("CharacterArmature|Run", 1.25)
			else:
				play_animation("CharacterArmature|Walk", 1.0)
		else:
			if is_crouching:
				play_animation("CharacterArmature|Idle", 0.5)
			else:
				play_animation("CharacterArmature|Idle", 1.0)
	else:
		if is_moving and is_sprinting:
			play_animation("CharacterArmature|Run", 0.85)
		else:
			play_animation("CharacterArmature|Walk", 0.5)

	# =====================================================
	# EXECUTE MOVEMENT
	# =====================================================

	move_and_slide()


# =========================================================
# HELPER FUNCTIONS
# =========================================================

func _has_ceiling_above() -> bool:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, CROUCH_HEIGHT, 0),
		global_position + Vector3(0, STANDING_HEIGHT + 0.15, 0),
		collision_mask,
		[get_rid()]
	)
	var result := space_state.intersect_ray(query)
	return not result.is_empty()


func play_animation(animation_name: String, speed: float = 1.0) -> void:
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name, -1.0, speed)
	else:
		animation_player.speed_scale = speed
