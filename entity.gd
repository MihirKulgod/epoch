extends Node

var entities := {
	"player": preload("res://scenes/player.tscn"),
	"dart": preload("res://scenes/enemy/dart/dart.tscn"),
	"arrow": preload("res://scenes/enemy/arrow/arrow.tscn")
}

func find(_name : String) -> Resource:
	if _name not in entities.keys():
		printerr("Entity \"" + _name + "\" does not exist!")
		return entities.values()[1]
	return entities.get(_name)
