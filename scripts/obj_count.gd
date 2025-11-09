extends Label

func _process(_delta: float) -> void:
	text = str(get_tree().get_node_count())
