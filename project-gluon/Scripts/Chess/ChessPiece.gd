extends Sprite2D

@onready var button = $Button

var board_x : int
var board_y : int

var is_white : bool

func _ready():
	button.pressed.connect(_on_pressed)

func _on_pressed():
	var chess_board = get_tree().get_first_node_in_group("chess_board")
	
	if chess_board:
		if chess_board.white == is_white:
			chess_board.set_selected_piece(board_x, board_y)
