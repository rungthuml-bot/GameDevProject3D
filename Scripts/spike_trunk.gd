extends Node3D

# ความเร็วการหมุน (ปรับตัวเลขตามต้องการ เช่น 0.3 คือหมุนช้ามาก, 1.0 คือหมุนปานกลาง)
@export var rotation_speed: float = 1 

func _process(delta: float) -> void:
	# สั่งให้หมุนรอบแกน Y (แกนตั้งสีเขียว)
	rotate_y(rotation_speed * delta)
