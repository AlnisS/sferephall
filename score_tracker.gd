extends Node

var last_time = 0.0
var best_time = 0.0

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
