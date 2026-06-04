extends Node2D

@onready var board: Node2D = $Board

const chess = preload("res://Scenes/chess.tscn")
const cards = preload("res://Scenes/cards.tscn")
const terrainPieces = preload("res://Scenes/terrain_pieces.tscn")

# Game ID's
# 1: Chess
# 2: Cards
# 3: Terrain pieces

var game1 : int = 1
var game2 : int = 3
var games : Array

@rpc("any_peer")
func _ready() -> void:
	
	games = [game1, game2]
	## First game ##
	match abs(game1):
		1:
			var new_chess = chess.instantiate()
			board.add_child(new_chess)
		2:
			var new_cards = cards.instantiate()
			board.add_child(new_cards)
		3: 
			var new_terrain_pieces = terrainPieces.instantiate()
			board.add_child(new_terrain_pieces)
	## Second game ##
	match abs(game2):
		1:
			var new_chess = chess.instantiate()
			board.add_child(new_chess)
		2:
			var new_cards = cards.instantiate()
			board.add_child(new_cards)
		3: 
			var new_terrain_pieces = terrainPieces.instantiate()
			board.add_child(new_terrain_pieces)

		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
