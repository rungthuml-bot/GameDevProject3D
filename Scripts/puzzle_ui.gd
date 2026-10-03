extends CanvasLayer


@onready var red_status: Label = $Panel/VBox/RedStatus
@onready var blue_status: Label = $Panel/VBox/BlueStatus
@onready var timer_label: Label = $Panel/VBox/Timer


func _ready() -> void:
	reset_display()


func reset_display() -> void:
	red_status.text = "Red: Waiting"
	blue_status.text = "Blue: Waiting"
	timer_label.text = "Time: --"


func update_red_pressed() -> void:
	red_status.text = "Red: ✓"


func update_blue_pressed() -> void:
	blue_status.text = "Blue: ✓"


func update_timer(time_left: float) -> void:
	timer_label.text = "Time: %.1f" % time_left


func show_completed() -> void:
	timer_label.text = "PUZZLE COMPLETE!"


func show_timeout() -> void:
	timer_label.text = "Time's up!"
