extends CharacterBody3D


# =========================================================
# MOVEMENT
# =========================================================

@export_category("Movement")

@export var move_speed: float = 5.0
@export var acceleration: float = 20.0
@export var deceleration: float = 20.0


# =========================================================
# JUMP
# =========================================================

@export_category("Jump")

@export var jump_height: float = 1.5
@export var gravity: float = 9.8


# =========================================================
# CAMERA
# =========================================================

@export_category("Camera")

@export var mouse_sensitivity: float = 0.002
@export var camera_min_angle: float = -35.0
@export var camera_max_angle: float = 45.0


# =========================================================
# NODE REFERENCES
# =========================================================

@onready var gimbal: Node3D = $Gimbal

@onready var camera: Camera3D = $Gimbal/Camera3D

@onready var animation_player: AnimationPlayer = $Eric/AnimationPlayer

@onready var interaction_area: Area3D = $InteractionArea


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	play_animation("CharacterArmature|Idle")

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
# INPUT
# =========================================================

func _unhandled_input(event: InputEvent) -> void:

	# =====================================================
	# MOUSE CAMERA
	# =====================================================

	if event is InputEventMouseMotion:

		# หมุน Player ซ้าย / ขวา
		rotate_y(
			-event.relative.x * mouse_sensitivity
		)

		# หมุนกล้องขึ้น / ลง
		gimbal.rotate_x(
			-event.relative.y * mouse_sensitivity
		)

		# จำกัดมุมกล้อง
		gimbal.rotation.x = clamp(
			gimbal.rotation.x,
			deg_to_rad(camera_min_angle),
			deg_to_rad(camera_max_angle)
		)


	# =====================================================
	# ESC — Pause (handled by HUD via ui_pause action)
	# =====================================================

	if event.is_action_pressed("ui_pause"):
		if UIManager.is_playing():
			# Let HUD handle the pause via UIManager
			return


	# =====================================================
	# LEFT CLICK
	# =====================================================

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# =========================================================
# PHYSICS
# =========================================================

func _physics_process(delta: float) -> void:

	# =====================================================
	# GRAVITY
	# =====================================================

	if not is_on_floor():

		velocity.y -= gravity * delta

	else:

		velocity.y = 0.0


	# =====================================================
	# JUMP
	# =====================================================

	if Input.is_action_just_pressed("jump"):

		if is_on_floor():

			velocity.y = sqrt(
				jump_height * 2.0 * gravity
			)


	# =====================================================
	# INPUT
	# =====================================================

	var input_2d := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)


	# =====================================================
	# PLAYER DIRECTION
	# =====================================================

	var forward := -global_transform.basis.z
	var right := global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()


	# =====================================================
	# MOVEMENT DIRECTION
	# =====================================================

	var direction := (
		right * input_2d.x
		- forward * input_2d.y
	)


	# =====================================================
	# MOVING
	# =====================================================

	if direction.length() > 0.01:

		direction = direction.normalized()

		velocity.x = move_toward(
			velocity.x,
			direction.x * move_speed,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			direction.z * move_speed,
			acceleration * delta
		)

		# Walk Animation
		play_animation("CharacterArmature|Walk")


	# =====================================================
	# IDLE
	# =====================================================

	else:

		velocity.x = move_toward(
			velocity.x,
			0.0,
			deceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			deceleration * delta
		)

		# Idle Animation
		play_animation("CharacterArmature|Idle")


	# =====================================================
	# MOVE
	# =====================================================

	move_and_slide()


# =========================================================
# ANIMATION
# =========================================================

func play_animation(animation_name: String) -> void:

	if animation_player.current_animation != animation_name:

		animation_player.play(animation_name)
