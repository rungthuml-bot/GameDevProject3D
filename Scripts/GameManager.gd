extends Node

var next_spawn_id: String = ""


func set_spawn_point(spawn_id: String) -> void:
	next_spawn_id = spawn_id


func get_spawn_point() -> String:
	return next_spawn_id


func clear_spawn_point() -> void:
	next_spawn_id = ""
