extends Node

var logPath := "user://run_log.jsonl"
var roundsPath := "res://rounds.jsonl"

var exePath = OS.get_executable_path().get_base_dir() + "/python/Scripts/python.exe"
var pyPath = OS.get_executable_path().get_base_dir() + "/ml/server.py"

@onready var fadeScene := preload("res://scenes/effects/fading.tscn")
@onready var loadScene := preload("res://scenes/ui/loading.tscn")
@onready var settingsScene := preload("res://scenes/ui/settings.tscn")

var blackout : Node = null
var loading : Node = null

var futurePlayerPositions := []

var processID := -1

var player : Player = null
var master : Master = null
var camera : Camera = null

var current_round := 11
var roundRunning := false

var target_future := true

var loss := 0.0
var epoch := 0
var max_epoch := 0
var trainingStarted := false
var trainingEnded := false

func _ready():
	var thread := Thread.new()
	var callable := Callable(self, "start_server_thread")
	thread.start(callable)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	current_round = Data.load_round()
	
func start_server_thread():
	processID = OS.create_process(
		exePath,
		[pyPath],
		false
	)

func shutdown_server():
	if processID < 0:
		print("server.py ended, process id " + str(processID))
		return
	
	OS.kill(processID)
	
	# Force close python execution
	# OS.execute("taskkill", ["/F", "/IM", "python.exe"])

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown_server()
		
		Data.save_round(current_round)
		
		for audio_source in get_tree().get_nodes_in_group("audio"):
			audio_source.stop()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not roundRunning:
			return
		if get_tree().get_first_node_in_group("settings"):
			get_tree().get_first_node_in_group("settings").queue_free()
			get_tree().paused = false
			return
		get_tree().paused = true
		var s := settingsScene.instantiate()
		get_tree().current_scene.add_child(s)
	if event.is_action_pressed("debug_force_quit"):
		quit()

func quit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func doLog():
	Logger_.finalize_log()

func sign(expr := true) -> int:
	return 1 if expr else -1

func nearest_vector(v : Vector2, vs : Array):
	var dr := vs.map(func(x): return abs(v.angle_to(x)))
	return vs[dr.find(dr.min())]

var DIAGONAL_AXES := [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)].map(func(x): return x.normalized())

func oneIn(x : int) -> bool:
	var r = randi_range(1, x)
	return r == 1

func createAt(object : Resource, position := Vector2.ZERO):
	var o = object.instantiate()
	o.global_position = position
	get_tree().current_scene.add_child(o)

func add_blackout():
	remove_blackout()
	
	blackout = fadeScene.instantiate()
	get_tree().root.call_deferred("add_child", blackout)

func remove_blackout():
	if blackout:
		blackout.queue_free()

func fade_in(time := 0.8):
	add_blackout()
	await get_tree().process_frame
	
	get_tree().paused = true
	await blackout.fade_in(time)
	get_tree().paused = false

func fade_out(time := 0.8):
	get_tree().paused = true
	await blackout.fade_out(time)
	await get_tree().create_timer(1).timeout
	get_tree().paused = false

func add_loading():
	loading = loadScene.instantiate()
	get_tree().current_scene.add_child(loading)

func clear_loading():
	if loading:
		loading.queue_free()
		loading = null

func get_predicted(i: int) -> Vector2:
	if i >= len(futurePlayerPositions) / 2:
		return Vector2(-100, -100)
	var j = i*2
	return Vector2(futurePlayerPositions[j], futurePlayerPositions[j+1])

func true_coords(vec : Vector2):
	var w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var h = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(vec.x * w, vec.y * h)

func false_coords(vec : Vector2):
	var w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var h = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(vec.x / w, vec.y / h)
