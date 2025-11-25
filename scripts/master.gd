extends Node

class_name Master

var round_override := -1

func _ready() -> void:
	Global.master = self
	if round_override > -1:
		Global.current_round = round_override
	Global.fade_in()
	call_deferred("load_round")
	
	await get_tree().create_timer(0.2).timeout
	$"../Cover".queue_free()

func load_round():
	var r : Dictionary = rounds[Global.current_round]
	Global.createAt(Entity.find("player"), true_coords(r.get("player_position")))
	var entities : Array = r.get("entities")
	for entry in entities:
		Global.createAt(Entity.find(entry.get("name")), true_coords(entry.get("position")))
	Global.roundRunning = true
	Logger_.init()
	
func die() -> void:
	if not Global.roundRunning:
		return
	Global.roundRunning = false
	await Global.fade_out()
	call_deferred("reload")

func reload():
	var result = get_tree().reload_current_scene()
	print("Reloaded current scene with code "+str(result))

func true_coords(vec : Vector2):
	var w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var h = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(vec.x * w, vec.y * h)

func check_round_beaten() -> void:
	if not Global.roundRunning:
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.is_queued_for_deletion():
			return
	Global.roundRunning = false
	await get_tree().create_timer(1).timeout
	await Global.fade_out()
	call_deferred("win_round")

func win_round():
	print("Round "+str(Global.current_round)+" has been beaten!")
	Global.doLog()
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

# All the waves are stored here
var rounds := [
	new_round(
		0,
		Vector2(0.5, 0.5),
		[
			new_entry("dart", Vector2(0.1, 0.1)),
			new_entry("dart", Vector2(0.9, 0.1)),
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
			new_entry("plus", Vector2(0.95, 0.05))
		]
	),
	new_round(
		3,
		Vector2(0.5, 0.05),
		[
			new_entry("plus", Vector2(0.05, 0.95)),
			new_entry("plus", Vector2(0.05, 0.05)),
			new_entry("plus", Vector2(0.95, 0.95)),
			new_entry("plus", Vector2(0.95, 0.05)),
		]
	),
]
