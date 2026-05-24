extends Node2D

@onready var board: Node2D = $Board

const chess = preload("res://Scenes/chess.tscn")
const cards = preload("res://Scenes/cards.tscn")

# Game ID's
# 1: Chess
# 2: Cards

var game1 : int = 1
var game2 : int = 2

@rpc("any_peer")
func _ready() -> void:
	
	## First game ##
	match abs(game1):
		1:
			var new_chess = chess.instantiate()
			board.add_child(new_chess)
		2:
			var new_cards = cards.instantiate()
			board.add_child(new_cards)
			
	## Second game ##
	match abs(game2):
		1:
			var new_chess = chess.instantiate()
			board.add_child(new_chess)
		2:
			var new_cards = cards.instantiate()
			board.add_child(new_cards)

		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
