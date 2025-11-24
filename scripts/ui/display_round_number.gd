extends RichTextLabel

func _ready() -> void:
	text = "ROUND "+ str(Global.current_round) +" BEATEN"
