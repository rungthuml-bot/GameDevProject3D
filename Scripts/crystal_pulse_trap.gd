extends Area3D

## CrystalPulseTrap — Periodic lethal crystal energy pulse in Level 7.
## 1. Cycle: Safe interval (3.0s) -> Warning telegraph (1.2s rapid pulsing flash) -> Surge pulse (0.8s lethal wave).
## 2. If the player is hit during the surge, triggers GameManager.trigger_trap_restart().
## 3. Includes strict tree guards and timer safety.

@export var trap_name: String = "Crystal Resonance Pulse"
@export var safe_duration: float = 3.0
@export var warning_duration: float = 1.2
@export var surge_duration: float = 0.8

@onready var pulse_light: OmniLight3D = get_node_or_null("PulseLight")
@onready var pulse_mesh: MeshInstance3D = get_node_or_null("PulseMesh")

var _is_active_wave: bool = false
var _player_inside: bool = false
var _loop_active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if pulse_light:
		pulse_light.light_energy = 0.3
		pulse_light.light_color = Color(0.2, 0.7, 1.0, 1.0)
	if pulse_mesh:
		pulse_mesh.visible = false
	
	_run_cycle()

func _exit_tree() -> void:
	_loop_active = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _is_active_wave:
			_hit_player()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _run_cycle() -> void:
	while _loop_active and is_inside_tree():
		# Phase 1: Safe window (Low ambient glow)
		_is_active_wave = false
		if pulse_light:
			pulse_light.light_energy = 0.3
			pulse_light.light_color = Color(0.2, 0.7, 1.0, 1.0)
		if pulse_mesh:
			pulse_mesh.visible = false
		
		await get_tree().create_timer(safe_duration).timeout
		if not _loop_active or not is_inside_tree():
			return
		
		# Phase 2: Warning Telegraph (Flashing warning glow & sound)
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr:
			audio_mgr.play_puzzle_warning_sfx(1.1)
		
		if pulse_light and is_inside_tree():
			var tw = create_tween()
			if tw:
				tw.set_loops(2)
				tw.tween_property(pulse_light, "light_energy", 3.0, warning_duration * 0.25)
				tw.parallel().tween_property(pulse_light, "light_color", Color(1.0, 0.25, 0.85, 1.0), warning_duration * 0.25)
				tw.tween_property(pulse_light, "light_energy", 0.6, warning_duration * 0.25)
		
		await get_tree().create_timer(warning_duration).timeout
		if not _loop_active or not is_inside_tree():
			return
		
		# Phase 3: Surge wave (Lethal discharge)
		_is_active_wave = true
		if audio_mgr:
			audio_mgr.play_door_sfx()
		
		if pulse_light:
			pulse_light.light_energy = 5.5
			pulse_light.light_color = Color(0.9, 0.2, 1.0, 1.0)
		if pulse_mesh:
			pulse_mesh.visible = true
		
		if _player_inside:
			_hit_player()
			return
		
		await get_tree().create_timer(surge_duration).timeout
		if not _loop_active or not is_inside_tree():
			return

func _hit_player() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null and gm.has_method("trigger_trap_restart"):
		gm.trigger_trap_restart(trap_name)
