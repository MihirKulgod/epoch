extends Node

var file : FileAccess

var frame_count := 0

func _ready() -> void:
	if FileAccess.file_exists(Global.logPath):
		file = FileAccess.open(Global.logPath, FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(Global.logPath, FileAccess.WRITE_READ)

func log_frame(player_state: Array, projectile_list: Array) -> void:
	var entry = {
		"frame": frame_count,
		"player": player_state,
		"projectiles": projectile_list
	}

	file.store_line(JSON.stringify(entry))
	frame_count += 1
