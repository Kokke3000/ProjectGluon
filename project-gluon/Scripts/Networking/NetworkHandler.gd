extends Node2D

const PORT: int = 42069

var ip_address: String = "localhost"
var peer: ENetMultiplayerPeer

var connection_timer: float = 0.0
var connecting := false
const TIMEOUT := 5.0

var game_manager

func _ready():
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)
	multiplayer.server_disconnected.connect(_on_disconnected)
	
	game_manager = get_tree().get_nodes_in_group("GameManager")

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 2)
	multiplayer.multiplayer_peer = peer


func start_client(ip) -> void:
	if ip != "localhost":
		ip_address = ip
	
	print("Attempting to join: ", ip_address)
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer

	connecting = true
	connection_timer = 0.0


func _process(delta):
	if connecting:
		connection_timer += delta

		if connection_timer > TIMEOUT:
			print("Connection timed out")
			stop_client()


func _on_connected():
	print("Connected to server")
	connecting = false
	connection_timer = 0.0


func _on_failed():
	print("Connection failed")
	stop_client()


func _on_disconnected():
	print("Disconnected from server")
	stop_client()


func stop_client():
	connecting = false

	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
