extends CharacterBody3D

const SPEED = 15
const JUMP_VELOCITY = 10

# ความไวเมาส์
@export var MOUSE_SENSITIVITY: float = 0.003

@onready var camera = $Camera3D

func _ready():
	# ซ่อนเคอร์เซอร์เมาส์และล็อคให้อยู่กลางจอ
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# ดักจับการขยับเมาส์เพื่อหมุนกล้องและตัวละคร
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	# แรงโน้มถ่วง
	if not is_on_floor():
		velocity += get_gravity() * delta

	# กระโดด
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# การเคลื่อนที่อิงตามทิศทางที่กล้อง/ตัวละครหันไป
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
