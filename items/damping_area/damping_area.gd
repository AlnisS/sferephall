extends Area

func _ready():
	$AnimationPlayer.play("placing")
	space_override = SPACE_OVERRIDE_DISABLED

func move_to_mouse(raycast):
	var center = raycast.position + raycast.normal * 1.01
	var collider_basis = raycast.collider.get_global_transform().basis
	look_at_from_position(center, center + collider_basis.x, collider_basis.y)

func place():
	$AnimationPlayer.play("lifespan")
	space_override = SPACE_OVERRIDE_COMBINE

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spawn":
		$AnimationPlayer.play("lifespan")
	if anim_name == "lifespan":
		$AnimationPlayer.play("despawn")
	if anim_name == "despawn":
		queue_free()


func _on_DampingArea_body_entered(body):
	pass
#	print(body)
