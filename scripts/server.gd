extends Node

signal reset_complete

var socket := WebSocketPeer.new()

var websocketURL = "ws://localhost:8766"

var timer := 0.0
var maxTime := 0.1

var connected := false

func _ready():
	connect_to_server()
	
func connect_to_server():
	var err = socket.connect_to_url(websocketURL)
	if err != OK:
		print("Connection error: ", err)

func _physics_process(delta):
	socket.poll()
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		
		timer += delta
		if timer > maxTime:
			timer = 0
			if Global.roundRunning:
				request_inference()
		
		while socket.get_available_packet_count():
			receive()

func request_reset():
	socket.send_text(JSON.stringify({
		"type": "reset"
	}))
	await self.reset_complete

func request_inference():
	if not Logger_.last_enemy_list:
		return
	socket.send_text(JSON.stringify({
		"type": "inference",
		"player": Logger_.last_player_state,
		"enemies": Logger_.last_enemy_list,
		"projectiles": Logger_.last_projectile_list
	}))
	
	if get_tree().get_first_node_in_group("record"):
		get_tree().get_first_node_in_group("record")._show()

func request_train():
	socket.send_text(JSON.stringify({
		"type": "train",
		"log_path": ProjectSettings.globalize_path(Global.logPath)
	}))

func receive():
	var raw_data = socket.get_packet().get_string_from_utf8()
	var data = JSON.parse_string(raw_data)
	
	if typeof(data) != TYPE_DICTIONARY:
		print("Unstructured packet received: " + str(raw_data))
		return
	
	if not data.has("type"):
		print("Packet message missing 'type': " + str(data))
		return
	
	match data["type"]:
		"connection_success":
			connected = true
		"prediction":
			received_prediction(data)
		"progress":
			received_progress(data)
		"train_start":
			received_start(data)
		"train_complete":
			received_end(data)
		"reset":
			reset(data)
		"error":
			printerr(str(data.get("message", "Unknown error message received!")))
		_:
			print("Received unknown packet type: " + str(data["type"]))

func reset(_data : Dictionary):
	emit_signal("reset_complete")

func received_end(_data : Dictionary):
	Global.trainingEnded = true

func received_start(data : Dictionary):
	Global.max_epoch = data.get("max_epoch", -1)
	Global.trainingStarted = true

func received_progress(data : Dictionary):
	Global.epoch = data.get("epoch", -1)
	Global.loss = data.get("loss", -1)

func received_prediction(data : Dictionary):
	var arr = data["prediction"]
	Global.futurePlayerPositions = arr
