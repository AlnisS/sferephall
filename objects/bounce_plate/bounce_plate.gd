extends RigidBody



func _on_BouncePlate_body_entered(body):
	$AnimationPlayer.play("bounce")
	$AudioStreamPlayer3D.pitch_scale = rand_range(0.8, 1.2)
	$AudioStreamPlayer3D.play()
	print("boing!")
