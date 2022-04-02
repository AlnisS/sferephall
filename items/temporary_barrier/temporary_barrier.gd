extends CSGBox

func _ready():
	$AnimationPlayer.play("spawn")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spawn":
		$AnimationPlayer.play("lifespan")
	if anim_name == "lifespan":
		$AnimationPlayer.play("despawn")
	if anim_name == "despawn":
		queue_free()
