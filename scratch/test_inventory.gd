extends Node

## Automated test suite for Inventory System
## Tests:
## 1. Input mapping for 'toggle_inventory'
## 2. InventoryUI scene structure and elements
## 3. GameManager item definitions and statuses
## 4. Item pickup and persistence across state
## 5. Item return at Altar
## 6. Inventory reset on new game
## 7. HUD integration & open/close toggle

var _passed_count: int = 0
var _failed_count: int = 0


func _ready() -> void:
	print("\n=== RUNNING INVENTORY SYSTEM TESTS ===")
	await get_tree().process_frame
	await get_tree().physics_frame
	
	test_input_mapping()
	test_game_manager_inventory_api()
	test_inventory_persistence_and_reset()
	test_inventory_ui_scene()
	test_hud_integration()
	
	print("\n=======================================")
	print("INVENTORY TEST RESULTS: %d PASSED, %d FAILED" % [_passed_count, _failed_count])
	print("=======================================\n")
	
	if _failed_count == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func assert_true(condition: bool, message: String) -> void:
	if condition:
		_passed_count += 1
		print("[PASS] " + message)
	else:
		_failed_count += 1
		printerr("[FAIL] " + message)


func assert_false(condition: bool, message: String) -> void:
	assert_true(not condition, message)


func assert_eq(a, b, message: String) -> void:
	if a == b:
		_passed_count += 1
		print("[PASS] %s (%s == %s)" % [message, str(a), str(b)])
	else:
		_failed_count += 1
		printerr("[FAIL] %s (Expected %s, got %s)" % [message, str(b), str(a)])


func test_input_mapping() -> void:
	print("\n--- Test 1: Input Mapping ---")
	assert_true(InputMap.has_action("toggle_inventory"), "InputMap has action 'toggle_inventory'")
	var events := InputMap.action_get_events("toggle_inventory")
	assert_true(events.size() > 0, "'toggle_inventory' has at least one event mapped")
	
	var is_key_i := false
	for ev in events:
		if ev is InputEventKey:
			if ev.physical_keycode == KEY_I or ev.keycode == KEY_I:
				is_key_i = true
				break
	assert_true(is_key_i, "'toggle_inventory' is mapped to Key 'I'")


func test_game_manager_inventory_api() -> void:
	print("\n--- Test 2: GameManager Inventory API ---")
	assert_true(GameManager != null, "GameManager singleton exists")
	
	# Initial clean state
	GameManager.reset_game_state()
	assert_false(GameManager.has_relic, "Initial has_relic is false")
	assert_false(GameManager.relic_returned, "Initial relic_returned is false")
	assert_false(GameManager.has_item("sovereign_relic"), "Initial has_item('sovereign_relic') is false")
	assert_false(GameManager.is_item_discovered("sovereign_relic"), "Initial is_item_discovered is false")
	assert_eq(GameManager.get_item_status("sovereign_relic"), "UNFOUND", "Initial item status is UNFOUND")
	
	# Check definition
	var item_def := GameManager.get_item_definition("sovereign_relic")
	assert_eq(item_def.get("name"), "The Sovereign Relic", "Relic name is correctly defined")
	assert_true(item_def.has("description"), "Relic has description")
	assert_true(item_def.has("lore"), "Relic has lore")
	assert_true(item_def.has("category"), "Relic has category")


var _inv_signal_counter: int = 0

func _on_test_inv_signal() -> void:
	_inv_signal_counter += 1


func test_inventory_persistence_and_reset() -> void:
	print("\n--- Test 3: Pickup, Altar Return, and Reset ---")
	
	_inv_signal_counter = 0
	GameManager.inventory_updated.connect(_on_test_inv_signal)
	
	# Simulate Pickup
	GameManager.set_relic_acquired(true)
	assert_true(_inv_signal_counter > 0, "GameManager emitted inventory_updated on relic acquired")
	assert_true(GameManager.has_relic, "GameManager.has_relic is now true")
	assert_true(GameManager.has_item("sovereign_relic"), "has_item('sovereign_relic') is true")
	assert_true(GameManager.is_item_discovered("sovereign_relic"), "is_item_discovered is true")
	assert_eq(GameManager.get_item_status("sovereign_relic"), "IN_POSSESSION", "Status is IN_POSSESSION")
	
	var status_info := GameManager.get_item_status_display("sovereign_relic")
	assert_true(status_info.get("is_possessed"), "Display status is_possessed is true")
	
	# Simulate Return to Altar
	var prev_signals := _inv_signal_counter
	GameManager.set_relic_returned(true)
	assert_true(_inv_signal_counter > prev_signals, "GameManager emitted inventory_updated on relic returned")
	assert_true(GameManager.relic_returned, "GameManager.relic_returned is true")
	assert_eq(GameManager.get_item_status("sovereign_relic"), "RETURNED", "Status is RETURNED")
	
	# Simulate New Game Reset
	prev_signals = _inv_signal_counter
	GameManager.reset_game_state()
	assert_true(_inv_signal_counter > prev_signals, "GameManager emitted inventory_updated on reset_game_state")
	assert_false(GameManager.has_relic, "has_relic is reset to false")
	assert_false(GameManager.relic_returned, "relic_returned is reset to false")
	assert_eq(GameManager.get_item_status("sovereign_relic"), "UNFOUND", "Status is reset to UNFOUND")
	
	GameManager.inventory_updated.disconnect(_on_test_inv_signal)


func test_inventory_ui_scene() -> void:
	print("\n--- Test 4: InventoryUI Scene Structure ---")
	var inv_scene: PackedScene = load("res://Scenes/UI/InventoryUI.tscn")
	assert_true(inv_scene != null, "InventoryUI.tscn loaded successfully")
	
	var inv_instance = inv_scene.instantiate()
	add_child(inv_instance)
	
	assert_true(inv_instance.has_node("CenterContainer/PanelContainer"), "Main modal PanelContainer exists")
	assert_true(inv_instance.has_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/SlotsSection/GridContainer"), "Slot GridContainer exists")
	assert_true(inv_instance.has_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/DetailSection"), "DetailSection exists")
	
	# Check slot generation
	var grid: GridContainer = inv_instance.get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentHBox/SlotsSection/GridContainer")
	assert_eq(grid.get_child_count(), 8, "Inventory has exactly 8 item slots generated")
	
	# Test Open and Close
	inv_instance.open_inventory()
	assert_true(inv_instance.visible, "InventoryUI is visible after open_inventory()")
	
	inv_instance.close_inventory()
	# Wait brief frame for tween or verify method works
	inv_instance.queue_free()


func test_hud_integration() -> void:
	print("\n--- Test 5: HUD Integration ---")
	var hud_scene: PackedScene = load("res://Scenes/UI/HUD.tscn")
	assert_true(hud_scene != null, "HUD.tscn loaded successfully")
	
	var hud = hud_scene.instantiate()
	add_child(hud)
	
	assert_true(hud.has_node("InventoryUI"), "HUD scene contains InventoryUI instance")
	assert_true(hud.has_node("MarginContainer/TopBar/LeftSection/InventoryHintLabel"), "HUD top bar contains InventoryHintLabel")
	
	var inv_node = hud.get_node("InventoryUI")
	assert_false(inv_node.visible, "InventoryUI starts hidden on HUD init")
	
	# Test HUD inventory toggle methods
	hud._open_inventory()
	assert_true(inv_node.visible, "InventoryUI opened via hud._open_inventory()")
	assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE, "Mouse mode set to VISIBLE when inventory opened")
	
	hud._close_inventory()
	hud.queue_free()
