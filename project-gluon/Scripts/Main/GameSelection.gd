extends Node2D

@onready var board: Node2D = $Board

const chess = preload("res://Scenes/chess.tscn")
const cards = preload("res://Scenes/cards.tscn")
const terrainPieces = preload("res://Scenes/terrain_pieces.tscn")

@onready var game_selection: Control = $"../GameSelection"

# Game ID's
# 0: Not selected
# 1: Chess
# 2: Cards
# 3: Terrain pieces

var selections := {}

var game_started := false

func _ready() -> void:
	game_selection.visible = false
	
@rpc("authority", "call_local", "reliable")
func game_begin() -> void:
	game_selection.visible = false

	var values = selections.values()

	if values.size() < 2:
		return

	instantiate_game(values[0])
	instantiate_game(values[1])

func instantiate_game(id: int):
	match id:
		1:
			board.add_child(chess.instantiate())
		2:
			board.add_child(cards.instantiate())
		3:
			board.add_child(terrainPieces.instantiate())

@rpc("any_peer", "reliable")
func select_game(game_id: int):
	var id = multiplayer.get_remote_sender_id()

	selections[id] = game_id

	print("Player", id, "picked", game_id, "selections:", selections)

	check_start_game()

	print("Player", id, "picked", game_id)

	check_start_game()

func _on_select_chess_pressed() -> void:
	select_game.rpc_id(1, 1)

func _on_select_cards_pressed() -> void:
	select_game.rpc_id(1, 2)

func _on_select_terrain_pressed() -> void:
	select_game.rpc_id(1, 3)

func check_start_game():
	if !multiplayer.is_server():
		return

	if game_started:
		return

	if selections.size() < 2:
		return

	game_started = true
	game_begin.rpc()
