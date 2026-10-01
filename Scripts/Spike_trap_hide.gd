extends Node3D

@onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.speed_scale = 0.5 
	
	var anim = anim_player.get_animation("Armature|Armature|SpikeTrap_HideAnimation|BaseLayer")
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR 
	anim_player.play("Armature|Armature|SpikeTrap_HideAnimation|BaseLayer")
