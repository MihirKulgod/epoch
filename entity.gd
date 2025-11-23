extends Node

var entities := {
	"player": preload("res://scenes/player.tscn"),
	"dart": preload("res://scenes/enemy/dart/dart.tscn"),
	"arrow": preload("res://scenes/enemy/arrow/arrow.tscn")
}

func find(name : String) -> Resource:
	if name not in entities.keys():
		printerr("Entity \"" + name + "\" does not exist!")
		return entities.values()[1]
	return entities.get(name)
