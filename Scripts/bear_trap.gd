extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var area_3d: Area3D = $Area3D

var is_triggered: bool = false

func _ready() -> void:
	if area_3d and not area_3d.body_entered.is_connected(_on_area_3d_body_entered):
		area_3d.body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.to_lower().contains("player") or body.is_in_group("player"):
		if not is_triggered:
			is_triggered = true
			print("กับดักหนีบแล้ว!")
			
			# 1. เล่นอนิเมชันหนีบ
			if anim_player.has_animation("Beartrap"):
				anim_player.play("Beartrap")
			
			# 2. ดูดตำแหน่ง Player เข้าสู่กลางกับดัก
			body.global_position.x = global_position.x
			body.global_position.z = global_position.z
			
			# 3. สั่งล็อกไม่ให้ Player กดเดินได้อีก
			if body.has_method("get_trapped"):
				body.get_trapped()
