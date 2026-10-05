extends Node

## GameManager — Autoload singleton for global game state, spawn points, and camera persistence.

var next_spawn_id: String = ""
var is_first_person: bool = false


func set_spawn_point(spawn_id: String) -> void:
	next_spawn_id = spawn_id


func get_spawn_point() -> String:
	return next_spawn_id


func clear_spawn_point() -> void:
	next_spawn_id = ""


func set_first_person(enabled: bool) -> void:
	is_first_person = enabled


func is_first_person_enabled() -> bool:
	return is_first_person
