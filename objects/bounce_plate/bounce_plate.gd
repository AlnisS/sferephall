extends RigidBody


func _process(delta):
	$AudioStreamPlayer3D.pitch_scale = Engine.time_scale


func _on_BouncePlate_body_entered(body):
	$AnimationPlayer.play("bounce")
	$AudioStreamPlayer3D.pitch_scale = rand_range(0.8, 1.2)
	$AudioStreamPlayer3D.play()
