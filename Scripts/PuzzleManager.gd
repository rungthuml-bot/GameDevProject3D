extends Node3D


@export_category("Puzzle")
@export var puzzle_time: float = 10.0


var red_pressed: bool = false
var blue_pressed: bool = false

var timer_active: bool = false
var remaining_time: float = 0.0

var puzzle_completed: bool = false

var puzzle_ui = null


func _ready() -> void:
	puzzle_ui = get_tree().get_first_node_in_group("puzzle_ui")

	if puzzle_ui == null:
		print("ERROR: PuzzleUI not found!")


func press_red() -> void:
	if puzzle_completed:
		return

	if red_pressed:
		return

	red_pressed = true

	print("Red pressed!")

	if puzzle_ui != null:
		puzzle_ui.update_red_pressed()

	if not timer_active and not blue_pressed:
		start_timer()

	check_puzzle()


func press_blue() -> void:
	if puzzle_completed:
		return

	if blue_pressed:
		return

	blue_pressed = true

	print("Blue pressed!")

	if puzzle_ui != null:
		puzzle_ui.update_blue_pressed()

	if not timer_active and not red_pressed:
		start_timer()

	check_puzzle()


func start_timer() -> void:
	timer_active = true
	remaining_time = puzzle_time

	if puzzle_ui != null:
		puzzle_ui.update_timer(remaining_time)

	print("Timer started: ", puzzle_time)


func _process(delta: float) -> void:
	if not timer_active:
		return

	remaining_time -= delta

	if remaining_time <= 0.0:
		remaining_time = 0.0

		if puzzle_ui != null:
			puzzle_ui.update_timer(0.0)

		reset_puzzle()
		return

	if puzzle_ui != null:
		puzzle_ui.update_timer(remaining_time)


func check_puzzle() -> void:
	if red_pressed and blue_pressed:
		puzzle_completed = true
		timer_active = false

		print("PUZZLE COMPLETED!")

		if puzzle_ui != null:
			puzzle_ui.show_completed()

		# Notify Door that puzzle has been solved
		var door = get_tree().current_scene.get_node_or_null("Door_To_Level3")

		if door != null:
			door.unlock_door()


func reset_puzzle() -> void:
	print("Time expired! Puzzle reset.")

	red_pressed = false
	blue_pressed = false

	timer_active = false
	remaining_time = 0.0

	if puzzle_ui != null:
		puzzle_ui.reset_display()
