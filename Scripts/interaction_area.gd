extends Area3D


var current_interactable: Area3D = null

var interaction_ui = null


func _ready() -> void:

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	interaction_ui = get_tree().get_first_node_in_group("interaction_ui")

	if interaction_ui != null:

		interaction_ui.message_closed.connect(_on_message_closed)


func _on_area_entered(area: Area3D) -> void:

	if not area.is_in_group("interactable"):
		return


	current_interactable = area


	# ถ้า UI กำลังเปิดอยู่
	# ไม่ต้องแสดง [E] ซ้ำ

	if interaction_ui != null and interaction_ui.is_showing:
		return


	if area.has_method("show_interaction_prompt"):

		area.show_interaction_prompt()


	print("Interactable detected: ", area.name)


func _on_area_exited(area: Area3D) -> void:

	if area != current_interactable:
		return


	if area.has_method("hide_interaction_prompt"):

		area.hide_interaction_prompt()


	current_interactable = null


	print("Interactable left: ", area.name)


func _unhandled_input(event: InputEvent) -> void:

	if not event.is_action_pressed("interact"):
		return


	# ==========================================
	# ถ้า UI กำลังเปิดอยู่
	# E = ปิด UI
	# ==========================================

	if interaction_ui != null and interaction_ui.is_showing:

		interaction_ui.hide_message()

		return


	# ==========================================
	# ถ้า UI ไม่ได้เปิด
	# E = Interact กับ Object
	# ==========================================

	if current_interactable == null:
		return


	if current_interactable.has_method("hide_interaction_prompt"):

		current_interactable.hide_interaction_prompt()


	if current_interactable.has_method("interact"):

		current_interactable.interact()


func _on_message_closed() -> void:

	# ถ้ายังยืนอยู่ใกล้ Object
	# ให้ [E] ตรวจสอบกลับมา

	if current_interactable == null:
		return


	if not is_instance_valid(current_interactable):
		current_interactable = null

		return


	if current_interactable.has_method("show_interaction_prompt"):

		current_interactable.show_interaction_prompt()
