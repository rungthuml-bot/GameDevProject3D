extends Area3D

## SanctumPressureTrap — Floor mechanism trap for Level 4.
## 1. Stepping on the pressure plate emits an audible click / warning rattle and light change.
## 2. After a 0.55s telegraph wind-up (giving the player time to react and dodge/dodge-step away),
##    it springs upwards with spikes / mechanical impulse.
## 3. If player is still within the trigger area, deals damage / knockback and triggers warning.
## 4. Fully respects game mechanics and resets safely.

@export var trap_name: String = "Sanctum Mechanism Trap"
@export var is_lethal: bool = false
@export var damage_amount: float = 25.0
@export var telegraph_duration: float = 0.55
@export var reset_delay: float = 2.4

@onready var plate_mesh: Node3D = get_node_or_null("PlateMesh")
@onready var warning_light: OmniLight3D = get_node_or_null("WarningLight")

var _is_triggered: bool = false
var _player_inside: bool = false
var _player_ref: CharacterBody3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if warning_light:
		warning_light.light_energy = 0.6
		warning_light.light_color = Color(1.0, 0.65, 0.2, 1.0)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if body is CharacterBody3D:
		_player_ref = body
	
	if not _is_triggered:
		_arm_and_spring_trap()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _arm_and_spring_trap() -> void:
	_is_triggered = true
	
	# Step 1: Warning Telegraph (Click & warning sound, plate depresses, light glows red)
	if has_node("/root/AudioManager"):
		AudioManager.play_puzzle_warning_sfx(1.2)
		AudioManager.play_button_sfx()
	
	if plate_mesh:
		var press_tw = create_tween()
		press_tw.tween_property(plate_mesh, "position:y", -0.08, 0.1)
	
	if warning_light:
		warning_light.light_energy = 3.5
		warning_light.light_color = Color(1.0, 0.15, 0.05, 1.0)
	
	# Telegraph delay — Player has a window to dodge out!
	if not is_inside_tree():
		return
	await get_tree().create_timer(telegraph_duration).timeout
	if not is_inside_tree():
		return
	
	# Step 2: Trap Springs!
	if has_node("/root/AudioManager"):
		AudioManager.play_door_sfx()
	
	# If player is still inside the trap area when it springs
	if _player_inside and is_instance_valid(_player_ref):
		if is_lethal:
			if GameManager:
				GameManager.trigger_trap_restart(trap_name)
			return
		
		# Knockback impulse
		var push_dir = (_player_ref.global_position - global_position).normalized()
		push_dir.y = 0.5
		if push_dir.length_squared() < 0.1:
			push_dir = Vector3(0, 0.5, 1)
		_player_ref.velocity = push_dir * 8.5
		
		# Feedback notification & sensory damage
		if has_node("/root/UIManager"):
			UIManager.notify_warning("Sprung a mechanical pressure plate trap! (-%d HP)" % int(damage_amount))
			if UIManager.has_method("trigger_damage_feedback"):
				UIManager.trigger_damage_feedback(damage_amount)
	
	# Step 3: Reset after delay
	if not is_inside_tree():
		return
	await get_tree().create_timer(reset_delay).timeout
	if not is_inside_tree():
		return
	
	if plate_mesh:
		var reset_tw = create_tween()
		if reset_tw:
			reset_tw.tween_property(plate_mesh, "position:y", 0.0, 0.3)
	
	if warning_light:
		warning_light.light_energy = 0.6
		warning_light.light_color = Color(1.0, 0.65, 0.2, 1.0)
	
	_is_triggered = false
