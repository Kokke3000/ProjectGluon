extends Sprite2D

@onready var button = $Button

var board_x : int
var board_y : int

func _ready():
	button.pressed.connect(_on_pressed)

func _on_pressed():
	var chess_board = get_tree().get_first_node_in_group("chess_board")

	if chess_board:
		chess_board.request_move.rpc_id(
			1,
			chess_board.selected_piece.x,
			chess_board.selected_piece.y,
			board_x,
			board_y
		)
