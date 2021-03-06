extends CSGBox

func _ready():
	$AnimationPlayer.play("placing")

func move_to_mouse(raycast):
	var center = raycast.position + raycast.normal * 1.01
	var collider_basis = raycast.collider.get_global_transform().basis
	look_at_from_position(center, center + collider_basis.y, collider_basis.x)
#	look_at_from_position(raycast.position, raycast.position + raycast.normal, Vector3.UP)

func place():
	$AnimationPlayer.play("lifespan")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spawn":
		$AnimationPlayer.play("lifespan")
	if anim_name == "lifespan":
		$AnimationPlayer.play("despawn")
	if anim_name == "despawn":
		queue_free()
