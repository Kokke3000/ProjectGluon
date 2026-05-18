extends Sprite2D

const BOARD_SIZE : int = 8
const CELL_SIZE : int = 5
const BOARD_BORDER : int = 2

const TEXTURE_HOLDER = preload("res://Scenes/texture_holder.tscn")

const BLACK_KING : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/black_king.png")
const BLACK_QUEEN : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/black_queen.png")
const BLACK_BISHOP : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/black_bishop.png")
const BLACK_KNIGHT : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/black_knight.png")
const BLACK_ROOK : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/black_rook.png")
const BLACK_PAWN : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/black_pawn.png")

const WHITE_KING : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/white_king.png")
const WHITE_QUEEN : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/white_queen.png")
const WHITE_BISHOP : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/white_bishop.png")
const WHITE_KNIGHT : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/white_knight.png")
const WHITE_ROOK : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/white_rook.png")
const WHITE_PAWN : CompressedTexture2D = preload("res://Sprites/chess-pieces-png/normals/white_pawn.png")


@onready var pieces: Node2D = $Pieces
@onready var dots: Node2D = $Dots
@onready var turn: Sprite2D = $Turn

# Piece ID's:
# -6 = black king
# -5 = black queen
# -4 = black rook
# -3 = black bishop
# -2 = black knight
# -1 = black pawn
# 0 = empty
# -6 = white king
# -5 = white queen
# -4 = white rook
# -3 = white bishop
# -2 = white knight
# -1 = white pawn


# false when selecting move, true when confirming move
var state : bool

var board : Array
var white : bool

var moves = []
var selected_piece : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_board()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !selected_piece:
		return

func set_selected_piece(x, y):
	selected_piece = Vector2(x, y)

			
func setup_board():
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	
	display_board()
	
func display_board():
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):

			var new_piece = TEXTURE_HOLDER.instantiate()
			pieces.add_child(new_piece)

			new_piece.position = Vector2(
				BOARD_BORDER + x * CELL_SIZE + CELL_SIZE / 2.0,
				BOARD_BORDER + y * CELL_SIZE + CELL_SIZE / 2.0
			)
		
			new_piece.scale = Vector2(0.3, 0.3)
			
			match board[y][x]:
				-6: new_piece.texture = BLACK_KING
				-5: new_piece.texture = BLACK_QUEEN
				-4: new_piece.texture = BLACK_ROOK
				-3: new_piece.texture = BLACK_BISHOP
				-2: new_piece.texture = BLACK_KNIGHT
				-1: new_piece.texture = BLACK_PAWN
				0: new_piece.texture = null
				6: new_piece.texture = WHITE_KING
				5: new_piece.texture = WHITE_QUEEN
				4: new_piece.texture = WHITE_ROOK
				3: new_piece.texture = WHITE_BISHOP
				2: new_piece.texture = WHITE_KNIGHT
				1: new_piece.texture = WHITE_PAWN
	
