extends Spatial

var temporary_barrier = preload("res://items/temporary_barrier/temporary_barrier.tscn")
var damping_area = preload("res://items/damping_area/damping_area.tscn")
var anti_gravity_area = preload("res://items/anti_gravity_area/anti_gravity_area.tscn")

#var active_item = temporary_barrier
#var active_item = damping_area
var active_item = anti_gravity_area

var item_instance = null

var mouse_position: Vector2 = Vector2.ZERO
var last_mouse_position: Vector2 = Vector2.ZERO

func _physics_process(delta):
	mouse_position = get_viewport().get_mouse_position()
	
	# camera movement
	_move_camera(Vector3(0, delta, 0))
	_rotate_camera()
	
	# item placement
	var mouse_in_world = _find_mouse_in_world(mouse_position)
	if mouse_in_world:
		_create_and_move_item(mouse_in_world)
		if Input.is_action_just_pressed("place"):
			_place_item()
	else:
		_remove_placing_visual()
	
	# misc housekeeping
	$SpotLightPivot.translation = $Ball.get_global_transform().origin
	_loop_track_music_if_needed()
	last_mouse_position = mouse_position



### CAMERA MOVEMENT ###

# get camera movement to keep ball centered in screen (smoothly)
# scale factors multiply each axis (e.g. delta or 0)
func _move_camera(scale_factors) -> void:
	# move camera vertically
	var ball_pos: Vector3 = $Ball.get_global_transform().origin
	var camera_pos: Vector3 = $CameraPivot.get_global_transform().origin
	# move to match position
	var movement: Vector3 = (ball_pos - camera_pos) * 2
	# an extra kick to help it "lead" the ball's velocity
	movement += $Ball.linear_velocity * 0.3
	movement *= scale_factors
	$CameraPivot.translate(movement)


# rotate camera if right mouse button is dragged
func _rotate_camera() -> void:
	if Input.is_action_pressed("rotate"):
		var angle: float = mouse_position.x - last_mouse_position.x
		angle *= -0.005
		$CameraPivot.rotate_y(angle)



### ITEM MANAGEMENT ###

func _create_and_move_item(raycast):
	# if no item is being placed, make a new one
	if item_instance == null:
		item_instance = active_item.instance()
		add_child(item_instance)
	# put the item at the mouse location
	item_instance.move_to_mouse(raycast)


func _place_item():
	item_instance.place()
	item_instance = null  # clear our reference so we can add more items


func _remove_placing_visual():
	if item_instance:
		item_instance.queue_free()
		item_instance = null



### UTILITIES ###

# find where mouse is in world space as a raycast
func _find_mouse_in_world(mouse_position) -> Dictionary:
	var ray_length = 1000
	var camera = $CameraPivot/Camera
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	return result


func _loop_track_music_if_needed():
	var music_position: float = $TrackMusic.get_playback_position()
	if music_position > 35.2:
		music_position -= 35.2
		$TrackMusic.seek(music_position)
