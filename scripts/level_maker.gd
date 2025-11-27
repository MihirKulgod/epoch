extends Node2D

@export var round_number := 0

func _ready() -> void:
	store()

func store() -> void:
	var wipe := true
	var file = FileAccess.open(Global.roundsPath, FileAccess.READ)
	if file == null:
		printerr("Previous rounds file not found, creating a new one.")
		file = FileAccess.open(Global.roundsPath, FileAccess.WRITE_READ)
	var data = JSON.parse_string(file.get_as_text())
	
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Invalid JSON format in: " + Global.roundsPath)
		if wipe:
			data = {}
		else:
			Global.call_deferred("quit")
			return
	
	var entities = []
	for e in get_tree().get_nodes_in_group("enemy"):
		entities.append({
			"name": e.get_entity_name(),
			"position": [Global.false_coords(e.global_position).x, Global.false_coords(e.global_position).y]
		})
	
	var playerPos = get_tree().get_first_node_in_group("player").global_position
	var new_round := {
		"number": round_number,
		"player_pos": [Global.false_coords(playerPos).x, Global.false_coords(playerPos).y],
		"entities": entities
	}
	
	if not data.has("rounds") or typeof(data["rounds"]) != TYPE_ARRAY:
		data["rounds"] = []
	
	data["rounds"].append(new_round)
	
	var json_text := JSON.stringify(data, "\t")
	var save_file := FileAccess.open(Global.roundsPath, FileAccess.WRITE)
	save_file.store_string(json_text)
