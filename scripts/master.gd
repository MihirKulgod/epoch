extends Node

class_name Master

var round_override := -1

func _ready() -> void:
	Global.master = self
	
	if round_override > -1:
		Global.current_round = round_override
	Global.fade_in()
	
	load_rounds()
	
	call_deferred("load_round")
	
	await get_tree().create_timer(0.2).timeout
	$"../Cover".queue_free()

func load_round():
	var r : Dictionary = rounds[Global.current_round]
	Global.createAt(Entity.find("player"), Global.true_coords(r.get("player_position")))
	var entities : Array = r.get("entities")
	for entry in entities:
		Global.createAt(Entity.find(entry.get("name")), Global.true_coords(entry.get("position")))
	Global.roundRunning = true
	Logger_.init()
	
func die() -> void:
	if not Global.roundRunning:
		return
	Global.doLog()
	Global.roundRunning = false
	await Global.fade_out()
	call_deferred("reload")

func reload():
	var _result = get_tree().reload_current_scene()

func check_round_beaten() -> void:
	if not Global.roundRunning:
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.is_queued_for_deletion():
			return
	Global.roundRunning = false
	await get_tree().create_timer(0.5).timeout
	$"../Beat Round".play()
	await Global.fade_out()
	call_deferred("win_round")

func win_round():
	print("round one")
	Global.doLog()
	print("logging over")
	if Global.current_round == rounds.back().get("number"):
		get_tree().change_scene_to_file('res://scenes/game_beaten.tscn')
		Global.current_round = 0
		return
	
	Global.current_round += 1
	get_tree().change_scene_to_file('res://scenes/win.tscn')

func new_entry(entity_name : String, pos : Vector2):
	return {
		"name": entity_name,
		"position": pos
	}

func new_round(number : int, playerPos : Vector2, entities : Array[Dictionary]) -> Dictionary:
	return {
		"number": number,
		"player_position": playerPos,
		"entities": entities
	}

func load_rounds():
	var file := FileAccess.open(Global.roundsPath, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Failed to parse rounds data!")
		Global.quit()
		return
		
	rounds = []
	for round in data["rounds"]:
		var playerPos = Vector2(round["player_pos"][0], round["player_pos"][1])
		var entities := []
		for entity in round["entities"]:
			entities.append({
				"name": entity["name"],
				"position": Vector2(entity["position"][0], entity["position"][1])
			})
		rounds.append({
			"number": round["number"],
			"player_position": playerPos,
			"entities": entities
		})
		
# All the waves are stored here
var rounds := [
	new_round(
		0,
		Vector2(0.5, 0.5),
		[
			new_entry("dart", Vector2(0.1, 0.05)),
			new_entry("dart", Vector2(0.9, 0.15)),
			new_entry("dart", Vector2(0.3, 0.75)),
			new_entry("dart", Vector2(0.7, 0.7)),
			new_entry("plus", Vector2(0.05, 0.95)),
			new_entry("plus", Vector2(0.05, 0.05))
		]
	),
	new_round(
		1,
		Vector2(0.5, 0.5),
		[
			new_entry("dart", Vector2(0.1, 0.1)),
			new_entry("dart", Vector2(0.9, 0.1)),
			new_entry("dart", Vector2(0.1, 0.9)),
			new_entry("dart", Vector2(0.9, 0.9)),
			new_entry("dart", Vector2(0.1, 0.5)),
			new_entry("dart", Vector2(0.9, 0.5)),
			new_entry("plus", Vector2(0.95, 0.95)),
			new_entry("plus", Vector2(0.95, 0.05))
		]
	),
	new_round(
		2,
		Vector2(0.05, 0.05),
		[
			new_entry("arrow", Vector2(0.95, 0.95)),
			new_entry("plus", Vector2(0.05, 0.95)),
			new_entry("plus", Vector2(0.5, 0.5)),
			new_entry("plus", Vector2(0.75, 0.75)),
			new_entry("plus", Vector2(0.95, 0.05))
		]
	),
	new_round(
		3,
		Vector2(0.05, 0.05),
		[
			new_entry("arrow", Vector2(0.95, 0.95))
		]
	),
]
