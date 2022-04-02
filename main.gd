extends Spatial

var temporary_barrier = preload("res://items/temporary_barrier/temporary_barrier.tscn")

var last_mouse_position: Vector2 = Vector2.ZERO

func _physics_process(delta):
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	
	# move camera vertically
	var ball_pos: Vector3 = $Ball.get_global_transform().origin
	var camera_pos: Vector3 = $CameraPivot.get_global_transform().origin
	# move to match position
	var movement: Vector3 = (ball_pos - camera_pos) * 2
	# an extra kick to help it "lead" the ball's velocity
	movement += $Ball.linear_velocity * 0.3
	$CameraPivot.translate(Vector3(0, movement.y * delta, 0))
	
	# rotate camera if right mouse button is dragged
	if Input.is_action_pressed("rotate"):
		var angle: float = mouse_position.x - last_mouse_position.x
		angle *= -0.005
		$CameraPivot.rotate_y(angle)
	
	if Input.is_action_just_pressed("place"):
		var ray_length = 1000
		var camera = $CameraPivot/Camera
		var from = camera.project_ray_origin(mouse_position)
		var to = from + camera.project_ray_normal(mouse_position) * ray_length
		var space_state = get_world().get_direct_space_state()
		var result = space_state.intersect_ray(from, to)
		if result:
			var instance = temporary_barrier.instance()
			add_child(instance)
			print(result.normal)
			instance.look_at_from_position(result.position, result.position + result.normal, Vector3.UP)
#			$Target.translation = result.position
	
	$SpotLightPivot.translation = $Ball.get_global_transform().origin
	
	var music_position: float = $TrackMusic.get_playback_position()
	if music_position > 35.2:
		music_position -= 35.2
		$TrackMusic.seek(music_position)
	
	last_mouse_position = mouse_position

