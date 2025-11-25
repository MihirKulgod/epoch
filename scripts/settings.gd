extends Node

var path := "user://settings.ini"

var settings := {
	"draw_future": false,
	"debug_info": false
}

func _ready() -> void:
	load_file()

func toggle(setting: String):
	if setting in settings.keys():
		settings[setting] = not settings[setting]

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_file()

func save_file() -> void:
	var file := ConfigFile.new()
	
	for key in settings.keys():
		file.set_value("Display", key, settings[key])
		
	var error := file.save(path)
	if error:
		print("An error occurred while saving settings data: ", error)

func load_file():
	var file := ConfigFile.new()
	var error := file.load(path)
	
	if error:
		print("An error occurred while loading settings data: ", error)
	
	for key in settings.keys():
		settings[key] = file.get_value("Display", key, false)
	
