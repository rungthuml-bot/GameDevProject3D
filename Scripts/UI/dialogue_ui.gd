extends CanvasLayer

## DialogueUI — Reusable Presentation Layer for narrative dialogues.
## Features typewriter text animation, speaker badges, skip option,
## and responsive cinematic dark fantasy styling.

@onready var dimmer: ColorRect = $Dimmer
@onready var dialogue_box: PanelContainer = $RootContainer/DialogueBox
@onready var speaker_badge: PanelContainer = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/HeaderRow/SpeakerBadge
@onready var speaker_label: Label = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/HeaderRow/SpeakerBadge/SpeakerLabel
@onready var skip_prompt: Label = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/HeaderRow/SkipPrompt
@onready var dialogue_text: Label = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/ContentRow/DialogueText
@onready var portrait_container: CenterContainer = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/ContentRow/PortraitContainer
@onready var continue_indicator: HBoxContainer = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/FooterRow/ContinueIndicator
@onready var indicator_arrow: Label = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/FooterRow/ContinueIndicator/IndicatorArrow
@onready var indicator_label: Label = $RootContainer/DialogueBox/MarginContainer/VBoxContainer/FooterRow/ContinueIndicator/IndicatorLabel

@export var typing_speed: float = 0.022

var is_open: bool = false
var is_typing: bool = false
var full_text: String = ""
var type_timer: float = 0.0
var is_last_line: bool = false

var _fade_tween: Tween = null
var _arrow_tween: Tween = null
var _last_type_sfx_time: float = 0.0


func _get_ui() -> Node:
	return get_node_or_null("/root/UIManager")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("dialogue_ui")

	# Initial hidden state
	visible = false
	dimmer.modulate.a = 0.0
	dialogue_box.modulate.a = 0.0
	continue_indicator.modulate.a = 0.0

	# Connect with UIManager signals
	var ui = _get_ui()
	if ui:
		ui.dialogue_started.connect(_on_dialogue_started)
		ui.dialogue_line_displayed.connect(_on_dialogue_line_displayed)
		ui.dialogue_ended.connect(_on_dialogue_ended)
		ui.settings_updated.connect(_apply_accessibility_settings)

	_apply_accessibility_settings()
	_start_indicator_pulse()


func _apply_accessibility_settings() -> void:
	if not is_instance_valid(dialogue_text):
		return
	var ui = _get_ui()
	if ui:
		# Text size: 0: Normal (16px), 1: Large (19px)
		var font_size := 16 if ui.text_size_index == 0 else 20
		dialogue_text.add_theme_font_size_override("font_size", font_size)


func _process(delta: float) -> void:
	if not is_open or not is_typing:
		return

	type_timer += delta
	while type_timer >= typing_speed and is_typing:
		type_timer -= typing_speed
		dialogue_text.visible_characters += 1

		# Play subtle typing sound on non-whitespace, non-punctuation characters
		var char_idx := dialogue_text.visible_characters - 1
		if char_idx >= 0 and char_idx < full_text.length():
			var c := full_text[char_idx]
			if not c in [" ", "\t", "\n", ".", ",", "!", "?", "-", "—", ":", ";", "'", "\"", "(", ")"]:
				_step_type_sfx()

		if dialogue_text.visible_characters >= full_text.length():
			_finish_typing_instant()
			break


func _step_type_sfx() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_type_sfx_time >= 0.065:
		_last_type_sfx_time = now
		var am = get_node_or_null("/root/AudioManager")
		if am:
			am.play_dialogue_typing()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	# Handle Advance keys (Space, Enter)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_handle_advance_input()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_TAB:
			# Skip / Close dialogue
			_handle_skip_input()
			get_viewport().set_input_as_handled()

	# Handle Mouse click
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_advance_input()
		get_viewport().set_input_as_handled()


func _handle_advance_input() -> void:
	if is_typing:
		# If typing, immediately display the full line
		_finish_typing_instant()
	else:
		# If finished typing, go to next line
		var ui = _get_ui()
		if ui:
			ui.next_dialogue()


func _handle_skip_input() -> void:
	var ui = _get_ui()
	if ui:
		ui.close_dialogue()


func _finish_typing_instant() -> void:
	is_typing = false
	dialogue_text.visible_characters = -1
	type_timer = 0.0

	# Reveal continue prompt
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(continue_indicator, "modulate:a", 1.0, 0.15)


# =========================================================
# SIGNAL HANDLERS
# =========================================================

func _on_dialogue_started(_id: String) -> void:
	is_open = true
	visible = true

	# Fade in dialogue box and cinematic dimmer
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(dimmer, "modulate:a", 1.0, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_fade_tween.tween_property(dialogue_box, "modulate:a", 1.0, 0.25) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _on_dialogue_line_displayed(speaker: String, text: String, _line_idx: int, _total: int, last_line: bool) -> void:
	is_last_line = last_line
	full_text = text

	# Update speaker
	if speaker.strip_edges().is_empty():
		speaker_badge.visible = false
	else:
		speaker_badge.visible = true
		speaker_label.text = speaker.to_upper()

	# Update footer label
	if is_last_line:
		indicator_label.text = "[Space] Close"
	else:
		indicator_label.text = "[Space] Next →"

	# Prepare typewriter
	continue_indicator.modulate.a = 0.0
	dialogue_text.text = full_text
	dialogue_text.visible_characters = 0
	type_timer = 0.0
	is_typing = true


func _on_dialogue_ended(_id: String) -> void:
	is_open = false
	is_typing = false

	# Fade out
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(dimmer, "modulate:a", 0.0, 0.22) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	_fade_tween.tween_property(dialogue_box, "modulate:a", 0.0, 0.22) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_fade_tween.chain().tween_callback(func(): visible = false)


# =========================================================
# INDICATOR ANIMATION
# =========================================================

func _start_indicator_pulse() -> void:
	if _arrow_tween and _arrow_tween.is_valid():
		_arrow_tween.kill()

	_arrow_tween = create_tween().set_loops()
	_arrow_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_arrow_tween.tween_property(indicator_arrow, "modulate:a", 0.4, 0.5) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_arrow_tween.tween_property(indicator_arrow, "modulate:a", 1.0, 0.5) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
