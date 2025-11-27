extends Node

var temp_path := "user://session_log.jsonl"
var real_path := Global.logPath

var file: FileAccess
var frame_count := 0

var last_player_state = null
var last_projectile_list = null
var last_enemy_list = null

func init() -> void:
	finalize_log()

	if FileAccess.file_exists(real_path):
		DirAccess.copy_absolute(
			ProjectSettings.globalize_path(real_path),
			ProjectSettings.globalize_path(temp_path)
		)
		
		var f := FileAccess.open(temp_path, FileAccess.READ)
		var last_line := ""
		while f.get_position() < f.get_length():
			last_line = f.get_line()
		f.close()
		
		if last_line != "":
			var parsed = JSON.parse_string(last_line)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("frame"):
				frame_count = parsed["frame"] + 1
				
		file = FileAccess.open(temp_path, FileAccess.READ_WRITE)
		file.seek_end()
		
	else:
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
		
	DirAccess.copy_absolute(
		ProjectSettings.globalize_path(temp_path),
		ProjectSettings.globalize_path(real_path)
	)

func clear() -> void:
	if FileAccess.file_exists(real_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(real_path))
		
	if FileAccess.file_exists(temp_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
		
	frame_count = 0
