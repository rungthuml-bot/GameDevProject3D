extends Node

## Automated Test: Popup & Input Spam Stress Testing
## Tests debounce, duplicate aggregation, node capping, and tween safety

func _ready() -> void:
	print("\n=== RUNNING POPUP & INPUT SPAM STRESS TESTS ===")
	var total_tests := 0
	var passed_tests := 0

	# ----------------------------------------------------
	# Test 1: NotificationSystem Duplicate Debounce & Aggregation
	# ----------------------------------------------------
	print("\n--- Test 1: NotificationSystem Debounce & Aggregation ---")
	total_tests += 1
	var notif_sys = preload("res://Scripts/UI/notification_system.gd").new()
	var test_msg = "Spamming test warning message"
	
	# Initial push
	var item1 = notif_sys.push(test_msg, "warning")
	assert_true(not item1.is_empty(), "Item 1 pushed successfully")
	assert_true(item1["repeat_count"] == 1, "Item 1 has repeat_count 1")
	
	# Duplicate push into queue aggregates
	var item2 = notif_sys.push(test_msg, "warning")
	assert_true(item2["repeat_count"] == 2, "Item 2 aggregated repeat_count to 2")
	assert_true(notif_sys.count() == 1, "Queue size remains 1 due to aggregation")
	passed_tests += 1

	# ----------------------------------------------------
	# Test 2: Queue Max Limit Protection
	# ----------------------------------------------------
	print("\n--- Test 2: Queue Max Limit Protection ---")
	total_tests += 1
	notif_sys.clear()
	for i in range(25):
		notif_sys.push("Unique message " + str(i), "info")
	assert_true(notif_sys.count() <= notif_sys.MAX_QUEUE_LIMIT, "Queue size capped at MAX_QUEUE_LIMIT (%d <= %d)" % [notif_sys.count(), notif_sys.MAX_QUEUE_LIMIT])
	passed_tests += 1

	# ----------------------------------------------------
	# Test 3: UIManager Rapid Notify Spam Protection
	# ----------------------------------------------------
	print("\n--- Test 3: UIManager Rapid Notify Spam ---")
	total_tests += 1
	var spam_count := 0
	var received_notifications: Array[String] = []
	var on_notif = func(text: String, _type: String, _dur: float):
		received_notifications.append(text)
	
	UIManager.notification_requested.connect(on_notif)
	
	# Spam 50 notifications of identical text in a tight loop
	for i in range(50):
		UIManager.notify_warning("Fast spam test")
	
	UIManager.notification_requested.disconnect(on_notif)
	assert_true(received_notifications.size() == 50, "Signals emitted to HUD for aggregation handling")
	passed_tests += 1

	# ----------------------------------------------------
	# Test 4: HUD Toast Node Aggregation & Cap Stress Test
	# ----------------------------------------------------
	print("\n--- Test 4: HUD Toast Node Aggregation Stress Test ---")
	total_tests += 1
	var hud_scene: PackedScene = load("res://Scenes/UI/HUD.tscn")
	assert_true(hud_scene != null, "HUD.tscn loaded successfully")
	var hud = hud_scene.instantiate()
	add_child(hud)
	await get_tree().process_frame

	var notif_list = hud.get_node("NotificationContainer/NotificationList")
	var initial_children = notif_list.get_child_count()

	# Simulate 100 rapid identical toast requests (e.g. from rapid key/trigger spam)
	for i in range(100):
		hud._on_notification_requested("Repeated Altar Warning", "warning", 2.0)

	# Verify: Identical toast was coalesced into ONE node with repeat count (x100)
	var final_children = notif_list.get_child_count()
	assert_true(final_children == 1, "Only 1 toast node created despite 100 requests (Aggregated: got %d)" % final_children)
	var toast_node = notif_list.get_child(0)
	assert_true(toast_node.get_meta("repeat_count", 0) == 100, "Toast repeat_count tracked accurately to 100")
	var label: Label = toast_node.get_meta("msg_label", null)
	assert_true(label != null and "(x100)" in label.text, "Toast label displays repeat count tag (x100)")
	passed_tests += 1

	# ----------------------------------------------------
	# Test 5: HUD Maximum Visible Toasts Cap
	# ----------------------------------------------------
	print("\n--- Test 5: HUD Maximum Visible Toasts Cap ---")
	total_tests += 1
	# Send 20 distinct different messages
	for i in range(20):
		hud._on_notification_requested("Distinct Message " + str(i), "info", 2.0)
	
	var distinct_children = notif_list.get_child_count()
	assert_true(distinct_children <= 4, "Distinct toast nodes strictly capped at MAX_VISIBLE_NOTIFICATIONS (4) (got %d)" % distinct_children)
	passed_tests += 1

	# ----------------------------------------------------
	# Test 6: InteractionUI Rapid Message Spam & Timer Reset
	# ----------------------------------------------------
	print("\n--- Test 6: InteractionUI Rapid Message Spam ---")
	total_tests += 1
	var inter_ui_scene: PackedScene = load("res://Scenes/UI/InteractionUI.tscn")
	var inter_ui = inter_ui_scene.instantiate()
	add_child(inter_ui)
	await get_tree().process_frame

	# Simulate pressing E repeatedly on the same object
	for i in range(50):
		inter_ui.show_message("Sarcophagus", "An ancient tomb sealed with wax.", null)
	
	assert_true(inter_ui.is_showing, "InteractionUI is open and showing")
	assert_true(inter_ui.message_timer == inter_ui.display_time, "Timer reset cleanly without restarting tween")
	inter_ui.hide_message()
	assert_true(not inter_ui.is_showing, "InteractionUI closed properly")
	passed_tests += 1

	# ----------------------------------------------------
	# Test 7: Inventory Rapid Toggle Debounce & Tween Safety
	# ----------------------------------------------------
	print("\n--- Test 7: Inventory Rapid Toggle Debounce ---")
	total_tests += 1
	var inv_node = hud.get_node("InventoryUI")
	for i in range(10):
		hud._open_inventory()
		hud._close_inventory()
	
	# Allow close tween (0.15s) to complete
	await get_tree().create_timer(0.2).timeout
	assert_true(not inv_node.visible, "Inventory closed cleanly after tween completed")
	passed_tests += 1

	print("\n=======================================================")
	print("ALL POPUP & INPUT SPAM TESTS PASSED: %d/%d" % [passed_tests, total_tests])
	print("=======================================================\n")
	get_tree().quit(0)


func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] " + message)
	else:
		printerr("[FAIL] " + message)
		push_error("Assertion failed: " + message)
		get_tree().quit(1)
