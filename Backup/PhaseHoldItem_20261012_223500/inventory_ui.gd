extends Control

## InventoryUI — Dark Fantasy In-Game Inventory Overlay
## Displays slot-based inventory with item icons, names, descriptions, and acquisition statuses.
## Allows toggling with 'I' or 'Escape', handles focus navigation, and integrates with GameManager.

signal inventory_closed

const THEME_ACCENT_GOLD := Color(0.85, 0.72, 0.45, 1.0)
const THEME_MUTED_GOLD := Color(0.78, 0.63, 0.36, 0.5)
const THEME_DIM_TEXT := Color(0.65, 0.62, 0.58, 0.75)
const THEME_LIGHT_TEXT := Color(0.92, 0.89, 0.82, 1.0)

# References
@onready var slot_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/SlotsSection/GridContainer
@onready var detail_panel: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox
@onready var detail_icon_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/IconHeader/IconContainer/IconLabel
@onready var detail_name_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/NameLabel
@onready var detail_category_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/CategoryLabel
@onready var detail_status_badge: PanelContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/StatusBadge
@onready var detail_status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/StatusBadge/StatusLabel
@onready var detail_desc_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/DescriptionLabel
@onready var detail_lore_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/LoreLabel
@onready var empty_guide_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection/DetailMargin/DetailVBox/EmptyGuideLabel
@onready var close_btn: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseButton

# Slot configuration
const TOTAL_SLOTS := 8
var _slot_buttons: Array[Button] = []
var _selected_item_id: String = "sovereign_relic"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_btn.pressed.connect(close_inventory)
	
	if GameManager:
		GameManager.inventory_updated.connect(_on_inventory_updated)
	
	_build_slots()
	refresh_inventory()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("toggle_inventory"):
		close_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_pause"):
		close_inventory()
		get_viewport().set_input_as_handled()


func open_inventory() -> void:
	visible = true
	modulate.a = 0.0
	refresh_inventory()
	
	# Select primary slot by default
	if not _slot_buttons.is_empty():
		_slot_buttons[0].grab_focus()
		_select_item("sovereign_relic")

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func close_inventory() -> void:
	if not visible:
		return

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		visible = false
		inventory_closed.emit()
	)


func _build_slots() -> void:
	for child in slot_grid.get_children():
		child.queue_free()
	_slot_buttons.clear()

	for i in range(TOTAL_SLOTS):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_ALL

		# Style the slot
		_apply_slot_style(btn, false, false)

		var slot_index := i
		btn.pressed.connect(func():
			if slot_index == 0:
				_select_item("sovereign_relic")
			else:
				_select_empty_slot(slot_index)
		)

		slot_grid.add_child(btn)
		_slot_buttons.append(btn)


func _apply_slot_style(btn: Button, is_filled: bool, is_active: bool) -> void:
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color(0.08, 0.07, 0.1, 0.85) if is_filled else Color(0.04, 0.035, 0.05, 0.6)
	style_normal.border_width_left = 1
	style_normal.border_width_top = 1
	style_normal.border_width_right = 1
	style_normal.border_width_bottom = 1
	style_normal.border_color = THEME_ACCENT_GOLD if is_active else (THEME_MUTED_GOLD if is_filled else Color(0.25, 0.22, 0.28, 0.5))
	style_normal.corner_radius_top_left = 4
	style_normal.corner_radius_top_right = 4
	style_normal.corner_radius_bottom_right = 4
	style_normal.corner_radius_bottom_left = 4

	var style_hover := style_normal.duplicate() as StyleBoxFlat
	style_hover.bg_color = Color(0.14, 0.12, 0.18, 0.9)
	style_hover.border_color = Color(0.95, 0.85, 0.55, 1.0)

	var style_focus := style_hover.duplicate() as StyleBoxFlat
	style_focus.border_width_left = 2
	style_focus.border_width_top = 2
	style_focus.border_width_right = 2
	style_focus.border_width_bottom = 2

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_hover)
	btn.add_theme_stylebox_override("focus", style_focus)


func refresh_inventory() -> void:
	if _slot_buttons.is_empty():
		return

	# Slot 0: Sovereign Relic (canonical item)
	var relic_btn := _slot_buttons[0]
	var has_relic: bool = GameManager and GameManager.has_relic
	var relic_returned: bool = GameManager and GameManager.relic_returned
	var discovered: bool = has_relic or relic_returned

	if discovered:
		relic_btn.text = "♚\nRelic"
		relic_btn.add_theme_font_size_override("font_size", 20)
		relic_btn.add_theme_color_override("font_color", THEME_ACCENT_GOLD if has_relic else Color(0.45, 0.85, 0.55, 1.0))
		_apply_slot_style(relic_btn, true, _selected_item_id == "sovereign_relic")
	else:
		relic_btn.text = "◇\nLocked"
		relic_btn.add_theme_font_size_override("font_size", 14)
		relic_btn.add_theme_color_override("font_color", THEME_DIM_TEXT)
		_apply_slot_style(relic_btn, false, _selected_item_id == "sovereign_relic")

	# Remaining slots are empty/locked
	for i in range(1, _slot_buttons.size()):
		var btn := _slot_buttons[i]
		btn.text = "—"
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", Color(0.35, 0.32, 0.38, 0.4))
		_apply_slot_style(btn, false, false)

	# Update details panel
	if _selected_item_id == "sovereign_relic":
		_select_item("sovereign_relic")


func _select_item(item_id: String) -> void:
	_selected_item_id = item_id
	var item_def := GameManager.get_item_definition(item_id) if GameManager else {}
	if item_def.is_empty():
		_select_empty_slot(-1)
		return

	var status_info := GameManager.get_item_status_display(item_id) if GameManager else {}
	var is_disc := GameManager.is_item_discovered(item_id) if GameManager else false

	empty_guide_label.visible = false
	detail_icon_label.visible = true
	detail_name_label.visible = true
	detail_category_label.visible = true
	detail_status_badge.visible = true
	detail_desc_label.visible = true
	detail_lore_label.visible = true

	if is_disc:
		detail_icon_label.text = item_def.get("icon_symbol", "♚")
		detail_icon_label.modulate = status_info.get("color", THEME_ACCENT_GOLD)
		detail_name_label.text = item_def.get("name", "Artifact")
		detail_category_label.text = item_def.get("category", "Item") + " • " + item_def.get("title_th", "")
		detail_status_label.text = status_info.get("text", "Possessed")
		detail_status_label.modulate = status_info.get("color", THEME_ACCENT_GOLD)
		detail_desc_label.text = item_def.get("description", "")
		detail_lore_label.text = "“" + item_def.get("lore", "") + "”"
	else:
		detail_icon_label.text = "◇"
		detail_icon_label.modulate = THEME_DIM_TEXT
		detail_name_label.text = "Ancient Relic (Unknown)"
		detail_category_label.text = "Undiscovered Artifact • วัตถุโบราณที่ยังไม่ถูกค้นพบ"
		detail_status_label.text = "Undiscovered / ยังไม่พบ"
		detail_status_label.modulate = THEME_DIM_TEXT
		detail_desc_label.text = "An empty velvet indentation awaits a legendary artifact from the dungeon's lowest crypt (Level 8)."
		detail_lore_label.text = "“Seek the deepest depths where shadows dwell...”"

	# Highlight slot
	for i in range(_slot_buttons.size()):
		if i == 0:
			_apply_slot_style(_slot_buttons[0], is_disc, true)
		else:
			_apply_slot_style(_slot_buttons[i], false, false)


func _select_empty_slot(slot_idx: int) -> void:
	_selected_item_id = ""
	empty_guide_label.visible = true
	detail_icon_label.visible = false
	detail_name_label.visible = false
	detail_category_label.visible = false
	detail_status_badge.visible = false
	detail_desc_label.visible = false
	detail_lore_label.visible = false

	empty_guide_label.text = "Slot #%d\n(Empty Slot / ช่องว่างสำรอง)\n\nAdditional items discovered in the labyrinth will be placed here." % (slot_idx + 1 if slot_idx >= 0 else 0)

	for i in range(_slot_buttons.size()):
		var is_disc: bool = (i == 0 and GameManager and (GameManager.has_relic or GameManager.relic_returned))
		_apply_slot_style(_slot_buttons[i], is_disc, i == slot_idx)


func _on_inventory_updated() -> void:
	if is_inside_tree() and visible:
		refresh_inventory()
