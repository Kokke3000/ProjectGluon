extends Node2D

const PORT: int = 42069

var ip_address: String = "localhost"
var peer: ENetMultiplayerPeer

var connection_timer: float = 0.0
var connecting := false
const TIMEOUT := 5.0

var game_manager

@onready var status: Label
@onready var game_selection: Control

func _ready():
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)
	multiplayer.server_disconnected.connect(_on_disconnected)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	game_manager = get_tree().get_first_node_in_group("GameManager")
	status = get_tree().get_first_node_in_group("StatusBox")

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 2)
	multiplayer.multiplayer_peer = peer
	status.text = "Server is running \n clients: 0"


func start_client(ip) -> void:
	if ip != "localhost":
		ip_address = ip
	
	status.text = ("Connecting to: " + ip_address)
	
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
			status.text = "Connection failed!"
			stop_client()


func _on_connected():
	status.text = ("Connected to server: " + ip_address)
	connecting = false
	connection_timer = 0.0


func _on_failed():
	status.text = "Connection failed!"
	print("Connection failed")
	stop_client()


func _on_disconnected():
	status.text = "Disconnected from server"
	print("Disconnected from server")
	stop_client()


func stop_client():
	connecting = false

	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		var count = multiplayer.get_peers().size()
		status.text = "Server running\nclients: %d" % count
		print("Client connected: ", id)
		
		# Show game selection once client is connected
		show_game_selection.rpc()
		
func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		var count = multiplayer.get_peers().size()
		status.text = "Server running\nclients: %d" % count
		print("Client disconnected: ", id)

@rpc("authority", "call_local", "reliable")
func show_game_selection():
	game_manager.game_selection.visible = true
