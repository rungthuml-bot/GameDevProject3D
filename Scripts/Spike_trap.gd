extends Node3D

@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer", true, false)

func _ready() -> void:
	if anim_player:
		var anim = anim_player.get_animation("Hazard_SpikeTrap_Armature|SpikeTrap_Activate")
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR
			
		anim_player.play("Hazard_SpikeTrap_Armature|SpikeTrap_Activate")
