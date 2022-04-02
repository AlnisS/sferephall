extends CSGBox

func _ready():
	$AnimationPlayer.play("placing")
#	$AnimationPlayer.play("spawn")

func move_to_mouse(result):
	look_at_from_position(result.position, result.position + result.normal, Vector3.UP)

func place():
	$AnimationPlayer.play("lifespan")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spawn":
		$AnimationPlayer.play("lifespan")
	if anim_name == "lifespan":
		$AnimationPlayer.play("despawn")
	if anim_name == "despawn":
		queue_free()
