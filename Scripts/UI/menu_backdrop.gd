extends Node3D

## MenuBackdrop — 3D world shown behind the Main Menu.
## Visual only: no physics, no interaction, no gameplay logic.
## Handles the cinematic camera drift, torch flicker and idle animation.

@export_category("Camera")
@export var camera_look_target: Vector3 = Vector3(-4.6, 1.55, -10.0)
@export var drift_amplitude: Vector3 = Vector3(0.18, 0.06, 0.0)
@export var drift_period: float = 26.0
@export var dolly_distance: float = 0.6
@export var dolly_duration: float = 40.0

@export_category("Torch")
@export var torch_flicker_amount: float = 0.12
@export var torch_flicker_speed: float = 6.0

@export_category("Character")
@export var idle_animation: String = "CharacterArmature|Idle"

@onready var camera: Camera3D = $MenuCamera
@onready var torch: OmniLight3D = $TorchLight
@onready var adventurer: Node3D = $Adventurer

var _time: float = 0.0
var _camera_origin: Vector3
var _torch_base_energy: float = 1.0
var _noise := FastNoiseLite.new()


func _ready() -> void:
	camera.current = true
	_camera_origin = camera.position
	_torch_base_energy = torch.light_energy
	_noise.frequency = 0.8
	_apply_camera(0.0)
	_play_idle()


func _process(delta: float) -> void:
	_time += delta
	_apply_camera(_time)

	# Very small, organic torch flicker
	var n := _noise.get_noise_1d(_time * torch_flicker_speed)
	torch.light_energy = _torch_base_energy * (1.0 + n * torch_flicker_amount)


func _apply_camera(t: float) -> void:
	# Slow sway + very slow push-in toward the corridor (eased, then holds)
	var phase := TAU * t / drift_period
	var sway := Vector3(
		sin(phase) * drift_amplitude.x,
		sin(phase * 0.5) * drift_amplitude.y,
		0.0
	)
	var push := ease(clampf(t / dolly_duration, 0.0, 1.0), -2.0) * dolly_distance
	var pos := _camera_origin + sway + Vector3(0.0, 0.0, -push)
	camera.look_at_from_position(pos, camera_look_target, Vector3.UP)


func _play_idle() -> void:
	var players := adventurer.find_children("*", "AnimationPlayer", true, false)
	if players.is_empty():
		return
	var anim_player := players[0] as AnimationPlayer
	if not anim_player.has_animation(idle_animation):
		return
	# Replay on finish instead of editing the shared imported Animation resource
	anim_player.animation_finished.connect(func(_name: StringName) -> void:
		anim_player.play(idle_animation)
	)
	anim_player.play(idle_animation)
