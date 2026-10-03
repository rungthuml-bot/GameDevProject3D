extends Area3D


@export_category("Interaction")
@export var interaction_text: String = "Enter"
@export var interaction_title: String = "Ancient Door"
@export_multiline var description: String = "Enter the next area."


@export_category("Level Transition")
@export_file("*.tscn") var target_scene: String
@export var target_spawn_id: String = ""


@export_category("Puzzle Requirement")
@export var require_puzzle: bool = false


@onready var interaction_label: Label3D = $InteractionLabel


var player: Node3D = null
var door_unlocked: bool = false


func _ready() -> void:
	# ทำให้ Door เป็น Interactable
	add_to_group("interactable")

	# ตั้งข้อความบน Label3D
	interaction_label.text = "[E] " + interaction_text

	# ซ่อน Label ตอนเริ่มเกม
	interaction_label.visible = false

	# หา Player
	player = get_tree().get_first_node_in_group("player")

	# ถ้าเป็นประตูธรรมดา
	# ให้ใช้งานได้ทันที
	if not require_puzzle:
		door_unlocked = true


func _process(_delta: float) -> void:
	if player == null:
		return

	# ทำให้ Label หันเข้าหาผู้เล่น
	var direction := player.global_position - interaction_label.global_position

	# ไม่ต้องหมุนตามแกน Y
	direction.y = 0.0

	if direction.length() < 0.01:
		return

	direction = direction.normalized()

	interaction_label.global_rotation.y = atan2(
		direction.x,
		direction.z
	)


func show_interaction_prompt() -> void:
	# ถ้าประตูยังล็อกอยู่ ไม่แสดง [E]
	if not door_unlocked:
		return

	interaction_label.visible = true


func hide_interaction_prompt() -> void:
	interaction_label.visible = false


func unlock_door() -> void:
	# ปลดล็อกประตู
	door_unlocked = true

	print("Door unlocked!")

	# ถ้าผู้เล่นอยู่ใกล้ประตูอยู่แล้ว
	# ให้แสดง [E] ทันที
	if player != null:
		interaction_label.visible = true


func interact() -> void:
	# ถ้าประตูยังล็อกอยู่ ไม่สามารถใช้งานได้
	if not door_unlocked:
		print("Door is locked!")
		return

	# ตรวจสอบว่ากำหนด Scene หรือยัง
	if target_scene.is_empty():
		print("ERROR: Target scene is not assigned!")
		return

	# ตรวจสอบว่า Spawn ID ถูกกำหนดหรือยัง
	if target_spawn_id.is_empty():
		print("ERROR: Target spawn ID is not assigned!")
		return

	# บอก GameManager ว่าเมื่อเข้า Scene ใหม่
	# ให้ Player ไปเกิดที่ Spawn ไหน
	GameManager.set_spawn_point(target_spawn_id)

	# เปลี่ยนไปยัง Level ถัดไป
	get_tree().change_scene_to_file(target_scene)


func _exit_tree() -> void:
	# ป้องกัน Label ค้างอยู่ตอนเปลี่ยน Scene
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
