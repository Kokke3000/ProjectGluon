extends Node2D

# Piece Id's
# 1: Plains

# Building Id's:
# 1: Tower


@onready var terrain_holder: GridContainer = $Hand/TabContainer/Terrain/TerrainHolder
@onready var building_holder: GridContainer = $Hand/TabContainer/Buildings/BuildingHolder

@onready var terrain_info: Label = $Hand/TerrainInfo

var player_pieces : Dictionary = {}
var pieces : Array

var terrain_piece = preload("res://Scenes/terrain_piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		
	terrain_info.visible = false

# When client connects -> Deal both hands
func _on_peer_connected(player_id: int) -> void:
	print("Peer joined:" , player_id)
	
	# Deal client hand
	starting_pieces(player_id, 3)
	
	# Deal host hand
	var host_id = 1
	starting_pieces(host_id, 3)
	

func starting_pieces(player_id: int, amount: int) -> void:
	if !player_pieces.has(player_id):
		player_pieces[player_id] = []
		print(player_pieces[player_id])

	# already dealt
	if player_pieces[player_id].size() > 0:
		return
		
	for i in amount:
		var piece := randi_range(1, 4)

		player_pieces[player_id].append(piece)
		rpc_id(player_id, "receive_piece", piece)

@rpc("authority", "call_local")
func receive_piece(piece: int) -> void:
	pieces.append(piece)
	add_piece(piece)


func add_piece(type: int) -> void:
	var new_piece = terrain_piece.instantiate()
	terrain_holder.add_child(new_piece)
	new_piece.update(type)
