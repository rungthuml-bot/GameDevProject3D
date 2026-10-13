extends Area3D

## GuardianStatue — Ancient guardian statue hazard guarding the throne chamber.
## Periodically charges up energy with an eye-glow telegraph, then releases a sweeping shockwave blast.

@export var guardian_name: String = "Ancient King's Guardian"
@export var charge_time: float = 1.4
@export var blast_duration: float = 0.6
@export var rest_time: float = 3.2
@export var damage_amount: float = 40.0
@export var is_lethal: bool = false

@onready var eye_light: OmniLight3D = get_node_or_null("EyeLight")
@onready var shockwave_mesh: Node3D = get_node_or_null("ShockwaveMesh")

var _player_inside: bool = false
var _is_blasting: bool = false
var _loop_active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if eye_light:
		eye_light.light_energy = 0.4
		eye_light.light_color = Color(0.4, 0.7, 1.0, 1.0)
	if shockwave_mesh:
		shockwave_mesh.visible = false
	
	_run_guardian_cycle()

func _exit_tree() -> void:
	_loop_active = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _is_blasting:
			_strike_player()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _run_guardian_cycle() -> void:
	while _loop_active and is_inside_tree():
		# 1. Dormant rest phase
		_is_blasting = false
		if eye_light:
			eye_light.light_energy = 0.4
			eye_light.light_color = Color(0.4, 0.7, 1.0, 1.0)
		if shockwave_mesh:
			shockwave_mesh.visible = false
		
		await get_tree().create_timer(rest_time).timeout
		if not _loop_active or not is_inside_tree():
			return
		
		# 2. Charging telegraph phase (Eyes burn intensely, warning hum)
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr:
			audio_mgr.play_puzzle_warning_sfx(0.9)
		
		if eye_light:
			var tw = create_tween()
			if tw:
				tw.tween_property(eye_light, "light_energy", 3.8, charge_time * 0.7)
				tw.parallel().tween_property(eye_light, "light_color", Color(1.0, 0.2, 0.1, 1.0), charge_time * 0.7)
		
		await get_tree().create_timer(charge_time).timeout
		if not _loop_active or not is_inside_tree():
			return
		
		# 3. Discharge blast phase
		_is_blasting = true
		if audio_mgr:
			audio_mgr.play_door_sfx()
		
		if shockwave_mesh:
			shockwave_mesh.visible = true
			var stw = create_tween()
			if stw:
				shockwave_mesh.scale = Vector3(0.2, 1.0, 0.2)
				stw.tween_property(shockwave_mesh, "scale", Vector3(1.2, 1.0, 1.2), blast_duration)
		
		if eye_light:
			eye_light.light_energy = 5.0
		
		if _player_inside:
			_strike_player()
		
		await get_tree().create_timer(blast_duration).timeout
		if not _loop_active or not is_inside_tree():
			return

func _strike_player() -> void:
	if is_lethal:
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("trigger_trap_restart"):
			gm.trigger_trap_restart(guardian_name)
		return
	
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_danger("Struck by %s's Divine Gaze! (-%d HP)" % [guardian_name, int(damage_amount)])
		if ui_mgr.has_method("trigger_damage_feedback"):
			ui_mgr.trigger_damage_feedback(damage_amount)
