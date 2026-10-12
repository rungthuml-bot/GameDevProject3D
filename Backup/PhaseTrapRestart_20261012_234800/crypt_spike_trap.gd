extends Area3D

## CryptSpikeTrap — Interactive floor trap that triggers warning rattle and pushes back player.
## Disables temporarily after triggering, and plays audio & visual warning.

@export var trap_name: String = "Ancient Spike Mechanism"
@export var is_armed: bool = true

@onready var spike_mesh: Node3D = get_node_or_null("SpikeMesh")
@onready var warning_light: OmniLight3D = get_node_or_null("WarningLight")

var _can_trigger: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if warning_light:
		warning_light.visible = true

func _on_body_entered(body: Node3D) -> void:
	if not _can_trigger or not is_armed:
		return
	if body.is_in_group("player"):
		_trigger_trap(body)

func _trigger_trap(player_node: Node3D) -> void:
	_can_trigger = false
	
	# Audio warning
	if has_node("/root/AudioManager"):
		AudioManager.play_puzzle_warning_sfx()
	
	# Push player back slightly and show warning notification
	if player_node is CharacterBody3D:
		var push_dir = (player_node.global_position - global_position).normalized()
		push_dir.y = 0.4
		player_node.velocity = push_dir * 7.0
	
	if has_node("/root/UIManager"):
		UIManager.notify_warning("A mechanical spike trap triggered beneath the stones!")
	
	# Visual flicker
	if warning_light:
		warning_light.light_energy = 4.0
		warning_light.light_color = Color(1.0, 0.2, 0.2, 1.0)
	
	# Reset after cooldown
	await get_tree().create_timer(2.5).timeout
	if warning_light:
		warning_light.light_energy = 1.5
		warning_light.light_color = Color(1.0, 0.4, 0.1, 1.0)
	_can_trigger = true
