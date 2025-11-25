extends Node

var temp_path := "user://session_log.jsonl"
var real_path := Global.logPath

var file: FileAccess
var frame_count := 0

var last_player_state = null
var last_projectile_list = null
var last_enemy_list = null

func init() -> void:
	file = FileAccess.open(temp_path, FileAccess.WRITE)
	frame_count = 0

func log_frame(player_state: Array, enemy_list: Array, projectile_list: Array) -> void:
	var entry = {
		"frame": frame_count,
		"player": player_state,
		"enemies": enemy_list,
		"projectiles": projectile_list
	}
	last_player_state = player_state
	last_enemy_list = enemy_list
	last_projectile_list = projectile_list
	
	file.store_line(JSON.stringify(entry))
	frame_count += 1

func finalize_log():
	if file:
		file.flush()
		file.close()
		
	DirAccess.copy_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(real_path))
