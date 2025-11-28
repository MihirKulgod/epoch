extends ColorRect

@onready var mat := material

func _process(_delta):
	if Global.player:
		mat.set("player_pos", Global.player.global_position)
