extends Node

var logPath := "user://run_log.jsonl"
var exePath = ProjectSettings.globalize_path("res://ml_env/Scripts/python.exe")
var pyPath = ProjectSettings.globalize_path("res://scripts/ml/")

var fadeScene := preload("res://scenes/effects/fading.tscn")
var blackout : Node = null

var futurePlayerPositions := []

var processID := -1

var player : Player = null
var master : Master = null

var current_round := 0
var roundRunning := false
var target_future := false

func _ready():
	var thread := Thread.new()
	var callable := Callable(self, "start_server_thread")
	thread.start(callable)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	current_round = Data.load_round()
	print("Round loaded as "+str(current_round))
	
func start_server_thread():
	processID = OS.create_process(
		exePath,
		[pyPath + "server.py"],
		true
	)

func shutdown_server():
	print("Shutting down python server..")
	
	if processID < 0:
		print("server.py ended, process id " + str(processID))
		return
	
	OS.kill(processID)
	
	#OS.execute("taskkill", ["/F", "/IM", "python.exe"])

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown_server()
		
		print("Round saved as "+str(current_round))
		Data.save_round(current_round)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		quit()
		
	if event.is_action_pressed("log"):
		doLog()
	
	if event.is_action_pressed("train"):
		train()

func quit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func doLog():
	print("Logging..")
	Logger_.finalize_log()
	print("Log file saved to " + ProjectSettings.globalize_path(logPath))

func train():
	var path = ProjectSettings.globalize_path(logPath)

	print("Starting training for: ", path)
	
	var output := []
	var exit_code := OS.execute(
		exePath,
		[pyPath + "train.py", path],
		output,
		true
	)

	print("Python training exited with code: ", exit_code)
	print("--- Python Output ---")
	for line in output:
		print(line)

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
