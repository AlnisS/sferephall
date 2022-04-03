extends Spatial


func _ready():
	$AnimationPlayer.play("placing")

func move_to_mouse(raycast):
	var center = raycast.position + raycast.normal * 0.25
	var collider_basis = raycast.collider.get_global_transform().basis
	look_at_from_position(center, center + collider_basis.x, collider_basis.y)

func place():
	$AnimationPlayer.play("countdown")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "countdown":
		for the_ball in get_tree().get_nodes_in_group("the_ball"):
			var ball_position = the_ball.get_global_transform().origin
			var explosion_position = get_global_transform().origin
			var displacement = ball_position - explosion_position
			var distance = displacement.length()
			var direction = displacement.normalized()
			var impulse = min(100, 10 / distance)
			the_ball.apply_central_impulse(direction * impulse)
		$AnimationPlayer.play("explode")
	if anim_name == "explode":
		queue_free()
