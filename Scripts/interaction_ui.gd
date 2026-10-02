extends CanvasLayer

signal message_closed

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/Margin/VBox/Title
@onready var description_label: Label = $Panel/Margin/VBox/Description
@onready var hint_label: Label = $Panel/Margin/VBox/HintContainer/Hint

@export var display_time: float = 4.0

var is_showing: bool = false
var current_interactable: Area3D = null
var message_timer: float = 0.0
var _tween: Tween = null


func _ready() -> void:
	panel.visible = false
	panel.modulate.a = 0.0


func show_message(
	title: String,
	description: String,
	interactable: Area3D
) -> void:

	current_interactable = interactable

	title_label.text = title
	description_label.text = description
	hint_label.text = "[E] Close"

	if _tween and _tween.is_valid():
		_tween.kill()

	panel.visible = true
	is_showing = true
	message_timer = display_time

	_tween = create_tween()
	_tween.tween_property(panel, "modulate:a", 1.0, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


func hide_message() -> void:

	if not is_showing:
		return

	is_showing = false
	message_timer = 0.0
	current_interactable = null

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(panel, "modulate:a", 0.0, 0.2) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	_tween.tween_callback(func():
		panel.visible = false
		message_closed.emit()
	)


func _process(delta: float) -> void:

	if not is_showing:
		return

	message_timer -= delta

	if message_timer <= 0.0:
		hide_message()

