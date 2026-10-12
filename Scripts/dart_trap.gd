extends Area3D

## DartTrap — Periodic rhythm projectile/spike dart volley trap in Level 8.
## 1. Interval: Safe period -> Telegraph audio/flash -> Lethal dart volley across passage.
## 2. If the player is caught in the volley zone without cover, deals damage or triggers trap restart.

@export var trap_name: String = "Ancient Dart Volley"
@export var is_lethal: bool = false
@export var damage_amount: float = 35.0
@export var safe_interval: float = 2.6
@export var telegraph_duration: float = 0.8
@export var volley_duration: float = 0.5

@onready var dart_mesh: Node3D = get_node_or_null("DartMesh")
@onready var telegraph_light: OmniLight3D = get_node_or_null("TelegraphLight")

var _player_inside: bool = false
var _is_firing: bool = false
var _loop_active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if telegraph_light:
		telegraph_light.light_energy = 0.2
		telegraph_light.light_color = Color(0.9, 0.4, 0.1, 1.0)
	if dart_mesh:
		dart_mesh.visible = false
	
	_run_trap_loop()

func _exit_tree() -> void:
	_loop_active = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _is_firing:
			_hit_player()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _run_trap_loop() -> void:
	while _loop_active and is_inside_tree():
		# 1. Safe Interval
		_is_firing = false
		if telegraph_light:
			telegraph_light.light_energy = 0.2
			telegraph_light.light_color = Color(0.9, 0.4, 0.1, 1.0)
		if dart_mesh:
			dart_mesh.visible = false
		
		await get_tree().create_timer(safe_interval).timeout
		if not _loop_active or not is_inside_tree():
			return
		
		# 2. Warning Telegraph (Click & warning flash)
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr:
			audio_mgr.play_puzzle_warning_sfx(1.3)
		
		if telegraph_light:
			var tw = create_tween()
			if tw:
				tw.tween_property(telegraph_light, "light_energy", 3.0, telegraph_duration * 0.5)
				tw.parallel().tween_property(telegraph_light, "light_color", Color(1.0, 0.1, 0.05, 1.0), telegraph_duration * 0.5)
				tw.tween_property(telegraph_light, "light_energy", 0.5, telegraph_duration * 0.5)
		
		await get_tree().create_timer(telegraph_duration).timeout
		if not _loop_active or not is_inside_tree():
			return
		
		# 3. Dart Volley Surge!
		_is_firing = true
		if audio_mgr:
			audio_mgr.play_door_sfx()
		
		if telegraph_light:
			telegraph_light.light_energy = 4.5
			telegraph_light.light_color = Color(1.0, 0.2, 0.1, 1.0)
		if dart_mesh:
			dart_mesh.visible = true
			var d_tw = create_tween()
			if d_tw:
				d_tw.tween_property(dart_mesh, "position:x", 1.8, volley_duration * 0.5)
				d_tw.tween_property(dart_mesh, "position:x", 0.0, volley_duration * 0.5)
		
		if _player_inside:
			_hit_player()
		
		await get_tree().create_timer(volley_duration).timeout
		if not _loop_active or not is_inside_tree():
			return

func _hit_player() -> void:
	if is_lethal:
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("trigger_trap_restart"):
			gm.trigger_trap_restart(trap_name)
		return
	
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr:
		ui_mgr.notify_danger("Hit by Dart Trap Volley! (-%d HP)" % int(damage_amount))
		if ui_mgr.has_method("trigger_damage_feedback"):
			ui_mgr.trigger_damage_feedback(damage_amount)
