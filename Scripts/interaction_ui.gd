extends CanvasLayer

signal message_closed

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/Margin/VBox/Title
@onready var description_label: Label = $Panel/Margin/VBox/Description
@onready var hint_label: Label = $Panel/Margin/VBox/HintContainer/Hint

@export var display_time: float = 3.0

var is_showing: bool = false
var current_interactable: Area3D = null
var message_timer: float = 0.0


func _ready() -> void:
	panel.visible = false


func show_message(
	title: String,
	description: String,
	interactable: Area3D
) -> void:

	current_interactable = interactable

	title_label.text = title
	description_label.text = description
	hint_label.text = "[E] Close"

	panel.visible = true
	is_showing = true

	message_timer = display_time


func hide_message() -> void:

	if not is_showing:
		return

	panel.visible = false

	is_showing = false

	message_timer = 0.0

	current_interactable = null

	message_closed.emit()


func _process(delta: float) -> void:

	if not is_showing:
		return

	message_timer -= delta

	if message_timer <= 0.0:
		hide_message()
