extends Node

var logPath = "user://run_log.jsonl"

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		#get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()
	
func quit():
	print("Quitting..")
	Logger_.file.flush()
	Logger_.file.close()
	print("Log file closed, output: " + ProjectSettings.globalize_path("user://"))
	train()

func train():
	var path = ProjectSettings.globalize_path(logPath)

	print("Starting training for: ", path)
	
	var pyPath = "res://scripts/ml/train.py"
	var exePath = ProjectSettings.globalize_path("res://ml_env/Scripts/python.exe")
	
	var output := []
	var exit_code := OS.execute(
		exePath,
		[ProjectSettings.globalize_path(pyPath), path],
		output,
		true
	)

	print("Python exited with code: ", exit_code)
	print("--- Python Output ---")
	for line in output:
		print(line)
