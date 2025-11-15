extends Node

var socket := WebSocketPeer.new()
var connected := false

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
	
	var player = get_tree().get_first_node_in_group("player")
	var projectiles = get_tree().get_nodes_in_group("projectile")

	var pos = player.global_position
	var vel = player.velocity

	var player_state = [pos.x, pos.y, vel.x, vel.y]

	var projectile_list = []
	for p in projectiles:
		projectile_list.append([
			p.global_position.x,
			p.global_position.y,
			p.linear_velocity.x,
			p.linear_velocity.y
		])

	Logger_.log_frame(player_state, projectile_list)
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		if not connected:
			print("GD> Connected to socket!")
		
		timer += delta
		
		if timer > maxTime:
			timer = 0
			socket.send_text(JSON.stringify({"player": player_state, "projectiles": projectile_list}))
		
		while socket.get_available_packet_count():
			var data = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			var arr = data["prediction"]
			Global.futurePlayerPos = Vector2(arr[0], arr[1])
			
