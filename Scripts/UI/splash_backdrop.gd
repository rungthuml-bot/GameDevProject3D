extends Node3D

## SplashBackdrop — 3D background behind the Title / Splash Screen.
## Visual only: dark cinematic dungeon corridor with distant torchlight.
## Handles subtle camera drift and organic torch flicker.

@export_category("Camera")
@export var camera_look_target: Vector3 = Vector3(0.0, 1.45, -10.5)
@export var drift_amplitude: Vector3 = Vector3(0.06, 0.03, 0.0)
@export var drift_period: float = 32.0
@export var dolly_distance: float = 0.45
@export var dolly_duration: float = 60.0

@export_category("Torch")
@export var torch_flicker_amount: float = 0.14
@export var torch_flicker_speed: float = 5.0

@onready var camera: Camera3D = $SplashCamera
@onready var torch: OmniLight3D = $TorchLight

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


func _process(delta: float) -> void:
	_time += delta
	_apply_camera(_time)

	# Organic gentle torch flicker
	var n := _noise.get_noise_1d(_time * torch_flicker_speed)
	torch.light_energy = _torch_base_energy * (1.0 + n * torch_flicker_amount)


func _apply_camera(t: float) -> void:
	var phase := TAU * t / drift_period
	var sway := Vector3(
		sin(phase) * drift_amplitude.x,
		sin(phase * 0.5) * drift_amplitude.y,
		0.0
	)
	var push := ease(clampf(t / dolly_duration, 0.0, 1.0), -2.0) * dolly_distance
	var pos := _camera_origin + sway + Vector3(0.0, 0.0, -push)
	camera.look_at_from_position(pos, camera_look_target, Vector3.UP)
