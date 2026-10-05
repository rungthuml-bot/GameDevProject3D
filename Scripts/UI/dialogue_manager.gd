class_name DialogueManager
extends RefCounted

## DialogueManager — Central narrative and dialogue state controller.
## Pure logic layer — manages line queues, progression, first-time tracking,
## and signals. Decoupled from UI rendering nodes.

const DialoguesData = preload("res://Data/UI/dialogues.gd")

signal dialogue_started(dialogue_id: String, total_lines: int)
signal dialogue_line_ready(speaker: String, text: String, line_index: int, total_lines: int, is_last: bool)
signal dialogue_ended(dialogue_id: String)

var current_dialogue: Dictionary = {}
var current_line_index: int = -1
var is_active: bool = false

# First-time tracking
var seen_dialogues: Dictionary = {}
var allow_replay_on_restart: bool = false


func start_dialogue(dialogue_id: String, force_replay: bool = false) -> bool:
	if not DialoguesData.has_dialogue(dialogue_id):
		print("DialogueManager: Dialogue ID not found: ", dialogue_id)
		return false

	var data := DialoguesData.get_dialogue(dialogue_id)
	return start_dialogue_data(data, force_replay)


func start_dialogue_data(data: Dictionary, force_replay: bool = false) -> bool:
	var id: String = data.get("id", "")
	var lines: Array = data.get("lines", [])

	if lines.is_empty():
		print("DialogueManager: Dialogue data has no lines!")
		return false

	# First-time check
	if not force_replay and not allow_replay_on_restart and has_seen(id):
		print("DialogueManager: Dialogue already seen, skipping: ", id)
		return false

	current_dialogue = data
	current_line_index = -1
	is_active = true

	# Mark seen
	mark_seen(id)

	dialogue_started.emit(id, lines.size())
	advance_line()
	return true


func advance_line() -> Dictionary:
	if not is_active:
		return {}

	var lines: Array = current_dialogue.get("lines", [])
	current_line_index += 1

	if current_line_index >= lines.size():
		close_dialogue()
		return {}

	var line: Dictionary = lines[current_line_index]
	var speaker: String = line.get("speaker", "Player")
	var text: String = line.get("text", "")
	var is_last := (current_line_index == lines.size() - 1)

	dialogue_line_ready.emit(speaker, text, current_line_index, lines.size(), is_last)
	return line


func close_dialogue() -> void:
	if not is_active:
		return

	var ended_id: String = current_dialogue.get("id", "")
	is_active = false
	current_dialogue = {}
	current_line_index = -1

	dialogue_ended.emit(ended_id)


func has_seen(id: String) -> bool:
	if id.is_empty():
		return false
	return seen_dialogues.get(id, false)


func mark_seen(id: String) -> void:
	if not id.is_empty():
		seen_dialogues[id] = true


func reset_seen() -> void:
	seen_dialogues.clear()


func set_allow_replay(allow: bool) -> void:
	allow_replay_on_restart = allow


func is_dialogue_active() -> bool:
	return is_active


func get_current_line() -> Dictionary:
	if not is_active:
		return {}
	var lines: Array = current_dialogue.get("lines", [])
	if current_line_index >= 0 and current_line_index < lines.size():
		return lines[current_line_index]
	return {}


func is_last_line() -> bool:
	if not is_active:
		return false
	var lines: Array = current_dialogue.get("lines", [])
	return current_line_index >= lines.size() - 1
