extends Node

var socket := WebSocketPeer.new()

var websocketURL = "ws://localhost:8766"

var timer := 0.0
var maxTime := 0.1

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
			
func request_inference():
	if not Logger_.last_player_state or not Logger_.last_projectile_list:
		return
	socket.send_text(JSON.stringify({
		"type": "inference",
		"player": Logger_.last_player_state,
		"projectiles": Logger_.last_projectile_list
	}))

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
		"prediction":
			received_prediction(data)
		"progress":
			received_progress(data)
		_:
			print("Received unknown packet type: " + str(data["type"]))

func received_progress(data : Dictionary):
	print("Received progress packet!")
	print(str(data["progress"]))

func received_prediction(data : Dictionary):
	print("Received prediction packet!")
	var arr = data["prediction"]
	Global.futurePlayerPositions = arr
