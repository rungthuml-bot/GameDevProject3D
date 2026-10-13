extends CanvasLayer

## QuestLogUI — Collapsible quest/objective log panel.
## Toggle with Tab key. Does NOT pause the game.
## Receives objective updates via UIManager signals in real-time.

@onready var panel: PanelContainer = $PanelContainer
@onready var objective_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ObjectiveList
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleRow/TitleLabel
@onready var hint_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HintLabel

const THEME_ACCENT_GOLD := Color(0.85, 0.72, 0.45, 1.0)
const THEME_GREEN_DONE := Color(0.45, 0.85, 0.55, 1.0)
const THEME_MUTED := Color(0.65, 0.62, 0.58, 0.75)
const THEME_LIGHT := Color(0.92, 0.89, 0.82, 1.0)

var is_open: bool = false
var _anim_tween: Tween = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("quest_log_ui")

	visible = true
	panel.modulate.a = 0.0
	panel.visible = false

	# Connect signals
	var ui = get_node_or_null("/root/UIManager")
	if ui:
		ui.objective_added.connect(_on_objectives_changed)
		ui.objective_completed.connect(_on_objectives_changed)
		ui.objective_removed.connect(_on_objectives_changed)
		ui.objectives_cleared.connect(_on_objectives_changed)

	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	# Tab key toggles the quest log without pausing
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			# Don't toggle during dialogue
			var ui = get_node_or_null("/root/UIManager")
			if ui and ui.is_dialogue_active():
				return
			toggle()
			get_viewport().set_input_as_handled()


func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	if is_open:
		return
	is_open = true
	_refresh()

	if _anim_tween and _anim_tween.is_valid():
		_anim_tween.kill()

	panel.visible = true
	_anim_tween = create_tween()
	_anim_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_anim_tween.tween_property(panel, "modulate:a", 1.0, 0.18) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func close() -> void:
	if not is_open:
		return
	is_open = false

	if _anim_tween and _anim_tween.is_valid():
		_anim_tween.kill()

	_anim_tween = create_tween()
	_anim_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_anim_tween.tween_property(panel, "modulate:a", 0.0, 0.14) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_anim_tween.tween_callback(func(): panel.visible = false)


func _on_objectives_changed(_id: String = "") -> void:
	if is_open:
		_refresh()


func _refresh() -> void:
	if not is_instance_valid(objective_list):
		return

	for child in objective_list.get_children():
		child.queue_free()

	var ui = get_node_or_null("/root/UIManager")
	var all_objs := []
	if ui:
		all_objs = ui.get_objectives()

	if all_objs.is_empty():
		hint_label.text = "No active objectives.\nExplore the dungeon..."
		hint_label.visible = true
		return

	hint_label.visible = false

	for obj in all_objs:
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 8)

		var bullet := Label.new()
		bullet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bullet.add_theme_font_size_override("font_size", 13)
		bullet.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.text = obj["text"]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 14)

		if obj["completed"]:
			bullet.text = "✓"
			bullet.add_theme_color_override("font_color", THEME_GREEN_DONE)
			label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55, 0.7))
		else:
			bullet.text = "◈"
			bullet.add_theme_color_override("font_color", THEME_ACCENT_GOLD)
			label.add_theme_color_override("font_color", THEME_LIGHT)

		row.add_child(bullet)
		row.add_child(label)
		objective_list.add_child(row)
