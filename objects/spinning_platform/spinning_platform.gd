extends RigidBody

func _physics_process(delta):
	rotate_object_local(Vector3(0, 1, 0), delta)
