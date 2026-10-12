class_name NotificationSystem
extends RefCounted

## NotificationSystem — Helper class for managing UI toast notifications.
## Provides styling, color mapping, and queue management for the HUD.

enum NotificationType {
	INFO,
	SUCCESS,
	WARNING,
	DANGER
}

const COLOR_INFO := Color(0.85, 0.72, 0.45, 1.0)      # Antique Gold
const COLOR_SUCCESS := Color(0.42, 0.85, 0.56, 1.0)   # Dungeon Emerald
const COLOR_WARNING := Color(0.96, 0.74, 0.28, 1.0)   # Amber Torch
const COLOR_DANGER := Color(0.92, 0.32, 0.32, 1.0)    # Crimson Blood

const ICON_INFO := "✦"
const ICON_SUCCESS := "✓"
const ICON_WARNING := "▲"
const ICON_DANGER := "✕"

const MAX_VISIBLE_NOTIFICATIONS := 4
const MAX_QUEUE_LIMIT := 10
const DEFAULT_DURATION := 3.5
const DUPLICATE_COOLDOWN_SEC := 1.2

var _queue: Array[Dictionary] = []
var _recent_history: Dictionary = {} # text -> timestamp_sec


static func parse_type(type_name: String) -> NotificationType:
	match type_name.to_lower():
		"success", "win", "complete":
			return NotificationType.SUCCESS
		"warning", "alert", "caution":
			return NotificationType.WARNING
		"danger", "error", "damage":
			return NotificationType.DANGER
		_:
			return NotificationType.INFO


static func get_color(type: NotificationType) -> Color:
	match type:
		NotificationType.SUCCESS:
			return COLOR_SUCCESS
		NotificationType.WARNING:
			return COLOR_WARNING
		NotificationType.DANGER:
			return COLOR_DANGER
		_:
			return COLOR_INFO


static func get_icon(type: NotificationType) -> String:
	match type:
		NotificationType.SUCCESS:
			return ICON_SUCCESS
		NotificationType.WARNING:
			return ICON_WARNING
		NotificationType.DANGER:
			return ICON_DANGER
		_:
			return ICON_INFO


func is_duplicate_spam(text: String) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	_clean_history(now)
	if _recent_history.has(text):
		var last_time: float = _recent_history[text]
		if (now - last_time) < DUPLICATE_COOLDOWN_SEC:
			return true
	return false


func record_notification(text: String) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	_recent_history[text] = now


func _clean_history(now: float) -> void:
	var keys_to_remove: Array[String] = []
	for k in _recent_history.keys():
		if (now - _recent_history[k]) > (DUPLICATE_COOLDOWN_SEC * 3.0):
			keys_to_remove.append(k)
	for k in keys_to_remove:
		_recent_history.erase(k)


func push(text: String, type_name: String = "info", duration: float = DEFAULT_DURATION) -> Dictionary:
	if text.strip_edges().is_empty():
		return {}

	var n_type := parse_type(type_name)

	# Check if this item already exists in the queue to coalesce/aggregate
	for item in _queue:
		if item.get("text", "") == text and item.get("type", NotificationType.INFO) == n_type:
			item["repeat_count"] = item.get("repeat_count", 1) + 1
			item["duration"] = duration
			return item

	# If queue exceeds limit, discard the oldest unserved notification
	if _queue.size() >= MAX_QUEUE_LIMIT:
		_queue.pop_front()

	var item := {
		"id": Time.get_ticks_msec(),
		"text": text,
		"type": n_type,
		"type_name": type_name,
		"duration": duration,
		"color": get_color(n_type),
		"icon": get_icon(n_type),
		"repeat_count": 1
	}
	_queue.append(item)
	return item


func get_next() -> Dictionary:
	if _queue.is_empty():
		return {}
	return _queue.pop_front()


func clear() -> void:
	_queue.clear()
	_recent_history.clear()


func count() -> int:
	return _queue.size()
