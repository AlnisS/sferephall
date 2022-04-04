extends Spatial

export var do_game = false

var explosion = preload("res://items/explosion/explosion.tscn")
var temporary_barrier = preload("res://items/temporary_barrier/temporary_barrier.tscn")
var damping_area = preload("res://items/damping_area/damping_area.tscn")
var anti_gravity_area = preload("res://items/anti_gravity_area/anti_gravity_area.tscn")

#var active_item = temporary_barrier
#var active_item = damping_area
#var active_item = anti_gravity_area
var active_item = null

var item_instance = null

var mouse_position: Vector2 = Vector2.ZERO
var last_mouse_position: Vector2 = Vector2.ZERO

var engine_time_scale_target = 1.0

var time = 0.0

var survival_time = 0.0

var money = 10.00

var temporary_hold = 0.0

func _ready():
	$LastTimeLabel.text = "Last time: " + _time_to_text(ScoreTracker.last_time)
	$BestTimeLabel.text = "Best time: " + _time_to_text(ScoreTracker.best_time)
#	$AnimationPlayer.play("setup_game")


func _physics_process(delta):
	time += delta
	
	var rot_phase = 1 * PI * 2.5 * time
	
	$BottomBar/ButtonExplosive.rect_rotation = sin(rot_phase) * 2
	$BottomBar/ButtonAntigrav.rect_rotation = sin(rot_phase + PI) * 2
	$BottomBar/ButtonDampen.rect_rotation = sin(rot_phase) * 2
	$BottomBar/ButtonBarrier.rect_rotation = sin(rot_phase + PI) * 2
	$BottomBar/ButtonSlowMotion.rect_rotation = sin(rot_phase) * 2
	
	$GameOverLabel.rect_rotation = sin(rot_phase) * 2
	
	$Title.rect_rotation = sin(rot_phase) * 1
	
	var scale_1 = 1 + sin(rot_phase) * 0.05
	var scale_2 = 1 + sin(rot_phase + PI) * 0.05
	$ButtonPlay.rect_scale = Vector2(scale_1, scale_2)
	$ButtonHelp.rect_scale = Vector2(scale_2, scale_1)
	$ButtonCredits.rect_scale = Vector2(scale_1, scale_2)
	
	
	_loop_menu_music_if_needed()
	
	if do_game:
		_game_actions(delta)
	else:
		$CameraPivot.rotate_y(cos(rot_phase) * 0.4 * delta)
#		rotation_degrees = Vector3(0, sin(rot_phase) * 2, 0)


func _game_actions(delta):
	survival_time += delta
	
	if survival_time > 1.5:
		$GoLabel.hide()
	else:
		var scl = 1 + survival_time * survival_time * survival_time
		$GoLabel.rect_scale = Vector2(scl, scl)
		$GoLabel.modulate = Color(1.0, 1.0, 1.0, 1.5 - survival_time)
	
	mouse_position = get_viewport().get_mouse_position()
	
	# camera movement
	_move_camera(Vector3(delta, delta, delta))
	_rotate_camera()
	
	# item placement
	var mouse_in_world = _find_mouse_in_world(mouse_position)
	if mouse_in_world and active_item:
		$Ball/BlockZone.show()
		_create_and_move_item(mouse_in_world)
		var blocked = false
		if active_item == explosion:
			blocked = _is_point_blocked(mouse_in_world.position)
		else:
			blocked = _is_point_blocked(mouse_in_world.position + mouse_in_world.normal)
		
		if blocked:
			$Ball/BlockZone.material.set_shader_param("color", Color(255, 0, 0, 0.2))
			if Input.is_action_just_released("place"):
				_cancel_item()
		else:
			$Ball/BlockZone.material.set_shader_param("color", Color(0, 255, 255, 0.2))
			if Input.is_action_just_released("place"):
				_place_item()
	else:
		_cancel_item()
	
	if Input.is_action_just_released("place"):
		money += temporary_hold
		temporary_hold = 0.0
	
	if engine_time_scale_target != 1.0:
		money -= delta * 0.5
		if money < 0.0:
			money = 0.0
			engine_time_scale_target = 1.0
	
	if not Input.is_action_pressed("place"):
		active_item = null
	
	# misc housekeeping
	$SpotLightPivot.translation = $Ball.get_global_transform().origin
	_loop_track_music_if_needed()
	_slow_motion_if_needed()
	
	$TimeLabel.text = "Time: " + _time_to_text(survival_time)
	$ItemsLabel.text = "Money: " + _money_to_text(money)
	
	if $Ball.get_global_transform().origin.y \
			< $GameOverHeight.get_global_transform().origin.y:
		game_over()
	
	last_mouse_position = mouse_position
	
	# cheats for development
#	if Input.is_action_pressed("ui_down"):
#		$Ball.add_central_force(Vector3(10, 0, 0))
#	if Input.is_action_pressed("ui_up"):
#		$Ball.add_central_force(Vector3(-10, 0, 0))
#	if Input.is_action_pressed("ui_left"):
#		$Ball.add_central_force(Vector3(0, 0, 10))
#	if Input.is_action_pressed("ui_right"):
#		$Ball.add_central_force(Vector3(0, 0, -10))


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
	movement += $Ball.linear_velocity * 0.2
	movement *= scale_factors
	$CameraPivot.translate($CameraPivot.to_local(camera_pos + movement))


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
	active_item = null
	temporary_hold = 0.0


func _cancel_item():
	$Ball/BlockZone.hide()
	_remove_placing_visual()


func _remove_placing_visual():
	if item_instance:
		item_instance.queue_free()
		item_instance = null



### UTILITIES ###

# find where mouse is in world space as a raycast
func _find_mouse_in_world(mouse_position) -> Dictionary:
	var ray_length = 1000
	var camera = $CameraPivot/CameraZero/Camera
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	return result


func _is_point_blocked(point: Vector3):
	return ($Ball/BlockZone.get_global_transform().origin.distance_to(point)
			< $Ball/BlockZone.radius)


func _loop_menu_music_if_needed():
	var music_position: float = $MenuMusic.get_playback_position()
	if music_position > 12.8:
		music_position -= 12.8
		$MenuMusic.seek(music_position)

func _loop_track_music_if_needed():
	var music_position: float = $TrackMusic.get_playback_position()
	if music_position > 35.2:
		music_position -= 35.2
		$TrackMusic.seek(music_position)


func _time_to_text(in_time: float) -> String:
	var minutes = floor(in_time / 60)
	var seconds = floor(in_time - minutes * 60)
	var decimal = floor(100 * (in_time - minutes * 60 - seconds))
	
	var result = ""
	
	if minutes < 10:
		result += "0"
	result += str(minutes)
	
	result += ":"
	
	if seconds < 10:
		result += "0"
	result += str(seconds)
	
	result += "."
	
	if decimal < 10:
		result += "0"
	result += str(decimal)
	
	return result

func _money_to_text(in_money: float) -> String:
	var dollars = floor(in_money)
	var cents = floor(100 * (in_money - dollars))
	
	var result = "$" + str(dollars) + "."
	
	if cents < 10:
		result += "0"
	result += str(cents)
	
	return result


func _slow_motion_if_needed():
	Engine.time_scale = lerp(Engine.time_scale, engine_time_scale_target, 0.2)
	
	$TrackMusic.pitch_scale = Engine.time_scale


func game_over():
	$TrackMusic.stop()
	$GameOverLabel.show()
	$ButtonReturn.show()
	do_game = false
	$BottomBar.hide()
	ScoreTracker.last_time = survival_time
	if survival_time > ScoreTracker.best_time:
		ScoreTracker.best_time = survival_time
	$MarbleRunTowers.hide()
	$GameOverSound.play()
	$Ball.hide()


### UI BUTTON CONNECTORS ###
func _on_ButtonExplosive_button_down():
	if not do_game:
		return
	if money >= 1.0:
		temporary_hold = 1.0
		money -= 1.0
		active_item = explosion

func _on_ButtonAntigrav_button_down():
	if not do_game:
		return
	if money >= 1.0:
		temporary_hold = 1.0
		money -= 1.0
		active_item = anti_gravity_area

func _on_ButtonDampen_button_down():
	if not do_game:
		return
	if money >= 1.0:
		temporary_hold = 1.0
		money -= 1.0
		active_item = damping_area

func _on_ButtonBarrier_button_down():
	if not do_game:
		return
	if money >= 1.0:
		temporary_hold = 1.0
		money -= 1.0
		active_item = temporary_barrier

func _on_ButtonSlowMotion_button_down():
	if not do_game:
		return
	if money > 0.0:
		engine_time_scale_target = 0.5

func _on_ButtonSlowMotion_button_up():
	engine_time_scale_target = 1.0

func _on_ButtonPlay_pressed():
	$AnimationPlayer.play("setup_game")

func _on_ButtonHelp_pressed():
	$InstructionsDialog.show()

func _on_ButtonCredits_pressed():
	$CreditsDialog.show()


func _on_ButtonReturn_pressed():
	get_tree().reload_current_scene()
