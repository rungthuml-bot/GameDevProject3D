extends Area3D

## PinnacleOfCoreAltar — Interactive Crystal Core ritual altar in Level 7.
## Connects player interaction to CrystalCavernManager.

@export_category("Interaction")
@export var interaction_text: String = "Commune"
@export var interaction_title: String = "Pinnacle of the Core"
@export_multiline var description: String = "The Master Crystal Pinnacle rests dormant in the ceremonial chamber."

@onready var interaction_label: Label3D = $InteractionLabel

var player: Node3D = null

func _ready() -> void:
	add_to_group("interactable")
	if interaction_label:
		interaction_label.text = "[E] " + interaction_text
		interaction_label.visible = false
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if player == null or interaction_label == null:
		return
	var direction := player.global_position - interaction_label.global_position
	direction.y = 0.0
	if direction.length() > 0.01:
		interaction_label.global_rotation.y = atan2(direction.x, direction.z)

func show_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = true

func hide_interaction_prompt() -> void:
	if interaction_label:
		interaction_label.visible = false

func interact() -> void:
	var mgr = get_tree().get_first_node_in_group("crystal_cavern_manager")
	if mgr != null:
		if not mgr.core_is_activated:
			var success = mgr.activate_core()
			var ui = get_tree().get_first_node_in_group("interaction_ui")
			if ui != null:
				ui.show_message(interaction_title, description, self)
			return
	
	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr:
		audio_mgr.play_interact_sfx()
	var ui = get_tree().get_first_node_in_group("interaction_ui")
	if ui != null:
		ui.show_message(interaction_title, description, self)

func _exit_tree() -> void:
	if is_instance_valid(interaction_label):
		interaction_label.visible = false
