extends Area3D

## SovereignSealPuzzle — Final puzzle dais before the Sovereign Relic chest in Level 8.
## 1. Requires 3 Ritual Altars to be awakened first.
## 2. Players solve the Sovereign Seal cipher by communing with the seal.
## 3. Once solved, dispels the barrier locking the Golden Relic Chest!

@onready var interaction_label: Label3D = $InteractionLabel
@onready var seal_light: OmniLight3D = get_node_or_null("SealLight")
@onready var seal_symbol: MeshInstance3D = get_node_or_null("SealSymbol")

var player: Node3D = null

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] Inspect Sovereign Seal"
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")
	
	if seal_light:
		seal_light.light_energy = 0.5
		seal_light.light_color = Color(1.0, 0.8, 0.3, 1.0)
	
	_update_visual_state()

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	_update_visual_state()
	if interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func _update_visual_state() -> void:
	var mgr = get_tree().get_first_node_in_group("throne_chamber_manager")
	if mgr != null and mgr.seal_puzzle_solved:
		if interaction_label:
			interaction_label.text = "[E] Sovereign Seal (Harmonized)"
		if seal_light:
			seal_light.light_energy = 3.5
			seal_light.light_color = Color(0.4, 0.9, 1.0, 1.0)

func interact() -> void:
	var mgr = get_tree().get_first_node_in_group("throne_chamber_manager")
	if mgr == null:
		return
	
	var ui = get_tree().get_first_node_in_group("interaction_ui")
	
	if mgr.seal_puzzle_solved:
		if ui != null:
			ui.show_message("Sovereign Seal (Harmonized)", "The golden cipher spins in celestial harmony. The sacred barrier locking the Sovereign Relic chest has dissolved!", self)
		return
	
	if not mgr.are_altars_completed():
		var ui_mgr = get_node_or_null("/root/UIManager")
		if ui_mgr:
			ui_mgr.notify_warning("The Seal is shrouded in slumber. Awaken all 3 Ritual Altars in the throne halls first (%d/%d activated)." % [mgr.get_active_altar_count(), mgr.required_altars])
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr:
			audio_mgr.play_interact_sfx()
		if ui != null:
			ui.show_message("Sovereign Seal of Eldoria", "Three golden rings locked by ancient warding. Hint from the Dynasty Stele: 'Only when the three ritual fires burn shall the monarch's heart reveal its truth.'", self)
		return
	
	# Altars are complete! Player solves the puzzle
	mgr.solve_seal_puzzle()
	_update_visual_state()
	
	if ui != null:
		ui.show_message("Sovereign Seal Dissolved!", "You align the three ancient rings of authority! Golden light surges into the velvet dais, unlocking the Golden Relic Chest containing the Sovereign Relic!", self)

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
