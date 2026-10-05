class_name ObjectiveManager
extends RefCounted

## ObjectiveManager — Manages objective data for the HUD.
## Pure data layer — does not create or manage UI nodes.
## The HUD reads this data to render the objective list.
##
## Usage (via UIManager API):
##   UIManager.add_objective("find_key", "Find the Key")
##   UIManager.complete_objective("find_key")
##   UIManager.remove_objective("find_key")
##   UIManager.clear_objectives()

var _objectives: Array[Dictionary] = []


func add(id: String, text: String) -> void:
	for obj in _objectives:
		if obj["id"] == id:
			return
	_objectives.append({"id": id, "text": text, "completed": false})


func complete(id: String) -> bool:
	for obj in _objectives:
		if obj["id"] == id and not obj["completed"]:
			obj["completed"] = true
			return true
	return false


func remove(id: String) -> bool:
	for i in range(_objectives.size()):
		if _objectives[i]["id"] == id:
			_objectives.remove_at(i)
			return true
	return false


func clear() -> void:
	_objectives.clear()


func get_all() -> Array[Dictionary]:
	return _objectives


func get_active() -> Array[Dictionary]:
	return _objectives.filter(func(o: Dictionary) -> bool: return not o["completed"])


func find_text(id: String) -> String:
	for obj in _objectives:
		if obj["id"] == id:
			return obj["text"]
	return ""


func has_objectives() -> bool:
	return not _objectives.is_empty()


func has_active() -> bool:
	for obj in _objectives:
		if not obj["completed"]:
			return true
	return false
