extends Node

var save_path := "user://save.ini"

func save_round(_round := 0) -> void:
	var file := ConfigFile.new()
	file.set_value("Game", "round", _round)
	
	var error := file.save(save_path)
	if error:
		print("An error happened while saving data: ", error)

func load_round() -> int:
	var file := ConfigFile.new()
	var error := file.load(save_path)
	
	if error:
		print("An error happened while loading data: ", error)
		return 0
	return file.get_value("Game", "round", 0)
	
