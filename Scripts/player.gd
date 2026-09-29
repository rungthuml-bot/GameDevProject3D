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


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# ล็อก Mouse ไว้กลางหน้าจอ
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# เปิดใช้กล้อง
	camera.current = true

	# เริ่มต้นด้วย Idle
	play_animation("CharacterArmature|Idle")


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

		# หมุน Gimbal ขึ้น / ลง
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
	# ESC
	# =====================================================

	if event is InputEventKey:

		if event.pressed and event.keycode == KEY_ESCAPE:

			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

			else:

				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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


	# ไม่ให้การก้ม/เงยของ Player มีผลกับการเดิน
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


	if direction.length() > 0.01:

		direction = direction.normalized()


		# =================================================
		# ACCELERATION
		# =================================================

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


		# =================================================
		# WALK ANIMATION
		# =================================================

		play_animation("CharacterArmature|Walk")


	else:

		# =================================================
		# DECELERATION
		# =================================================

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


		# =================================================
		# IDLE ANIMATION
		# =================================================

		play_animation("CharacterArmature|Idle")


	# =====================================================
	# MOVE PLAYER
	# =====================================================

	move_and_slide()


# =========================================================
# PLAY ANIMATION
# =========================================================

func play_animation(animation_name: String) -> void:

	# ถ้า Animation นี้กำลังเล่นอยู่
	# ไม่ต้องสั่งเล่นซ้ำทุก frame

	if animation_player.current_animation != animation_name:

		animation_player.play(
			animation_name
		)
