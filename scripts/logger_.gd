extends Node

var file := FileAccess.open(Global.logPath, FileAccess.WRITE)
var frame_count := 0

func log_frame(player_state: Array, projectile_list: Array) -> void:
	var entry = {
		"frame": frame_count,
		"player": player_state,
		"projectiles": projectile_list
	}

	file.store_line(JSON.stringify(entry))
	frame_count += 1
