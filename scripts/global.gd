extends Node

var logPath = "user://run_log.jsonl"
var exePath = ProjectSettings.globalize_path("res://ml_env/Scripts/python.exe")
var pyPath = ProjectSettings.globalize_path("res://scripts/ml/")

var futurePlayerPos := Vector2.ZERO

var serverRunning := false
var processID := -1

func _ready():
	var thread := Thread.new()
	var callable := Callable(self, "start_server_thread")
	thread.start(callable)
	
func start_server_thread():
	serverRunning = true
	#var output := []
	processID = OS.create_process(
		exePath,
		[pyPath + "server.py"],
		true
	)

	#print("Python server exited with code: ", exit_code)
	#print("--- Python Output ---")
	#for line in output:
		#print(line)
	serverRunning = false

func shutdown_server():
	print("Shutting down python server..")
	print("Is server still running? The answer is "+str(serverRunning))
	
	if processID < 0:
		print("server.py ended, process id " + str(processID))
		return
	
	OS.kill(processID)
	
	#OS.execute("taskkill", ["/F", "/IM", "python.exe"])

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		shutdown_server()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
		
	if event.is_action_pressed("train"):
		doLog()
	
func doLog():
	print("Logging..")
	Logger_.file.flush()
	Logger_.file.close()
	print("Log file closed, output: " + ProjectSettings.globalize_path("user://"))
	train()

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
