extends RichTextLabel

var phase := 0
# 0 Not started, 1 started, 2 ended

func _process(_delta: float) -> void:
	phase = 0 if not Global.trainingStarted else 1
	if Global.trainingEnded:
		phase = 2
	
	match phase:
		0:
			text = "Waiting to start training.."
		1:
			text = "Training.. "
		2:
			text = "Training complete! Final Loss = "+str(round(Global.loss*10)/10.0)
