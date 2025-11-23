extends Node

class_name Master

@onready var blackout : Blackout = $"../Black"

var current_round := 0

func _ready() -> void:
	Global.master = self
	start()
	call_deferred("load_round")

func load_round():
	var r : Dictionary = rounds[current_round]
	Global.createAt(Entity.find("player"), true_coords(r.get("player_position")))
	var entities : Array = r.get("entities")
	for entry in entities:
		Global.createAt(Entity.find(entry.get("name")), true_coords(entry.get("position")))
	
func start() -> void:
	get_tree().paused = true
	await blackout.ready
	await blackout.fade_in(1)
	get_tree().paused = false

func end() -> void:
	get_tree().paused = true
	await blackout.fade_out(1.5)
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	
func die() -> void:
	end()
	get_tree().call_deferred("reload_current_scene")

func true_coords(vec : Vector2):
	var w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var h = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(vec.x * w, vec.y * h)

func check_round_beaten() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.is_queued_for_deletion():
			return
	await get_tree().create_timer(1).timeout
	await end()
	call_deferred("win_round")

func win_round():
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
			new_entry("arrow", Vector2(0.05, 0.05)),
			new_entry("arrow", Vector2(0.95, 0.05)),
		]
	),
]
