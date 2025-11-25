extends Node

var temp_path := "user://session_log.jsonl"
var real_path := Global.logPath

var file: FileAccess
var frame_count := 0

var last_player_state = null
var last_projectile_list = null

func _ready() -> void:
	file = FileAccess.open(temp_path, FileAccess.WRITE)
	frame_count = 0

func log_frame(player_state: Array, projectile_list: Array) -> void:
	var entry = {
		"frame": frame_count,
		"player": player_state,
		"projectiles": projectile_list
	}
	last_player_state = player_state
	last_projectile_list = projectile_list

	file.store_line(JSON.stringify(entry))
	frame_count += 1

func finalize_log():
	if file:
		file.flush()
		file.close()
		
	DirAccess.copy_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(real_path))
