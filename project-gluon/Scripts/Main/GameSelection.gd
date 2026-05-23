extends Node2D

@onready var chess: Node2D = $Board/Chess
@onready var cards: Node2D = $Board/Cards


# Game ID's
# 1: Chess
# 2: Cards

var game1 : int = 1
var game2 : int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match abs(game1):
		1:
			chess.visible = true
		2:
			cards.visible = true
		
	match abs(game2):
		1:
			chess.visible = true
		2:
			cards.visible = true

		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
