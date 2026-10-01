extends Node3D

func _ready() -> void:
	play_all_pistons()

func play_all_pistons() -> void:
	for piston in $Pistons.get_children():
		var anim_player = piston.get_node_or_null("AnimationPlayer")
		if anim_player and anim_player.has_animation("Push_out"):
			var anim = anim_player.get_animation("Push_out")
		
			for i in range(anim.get_track_count()):
				var track_path = str(anim.track_get_path(i))
				if "position" in track_path:
					anim.track_set_path(i, ".:position")
		
			anim_player.play("Push_out")
