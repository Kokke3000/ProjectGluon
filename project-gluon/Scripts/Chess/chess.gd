extends Sprite2D

const BOARD_SIZE : int = 8
const CELL_SIZE : int = 5
const BOARD_BORDER : int = 2
const PIECE_SIZE : Vector2 = Vector2(0.3,0.3)
const MOVE_DOT_SIZE : Vector2 = Vector2(0.3,0.3)

const PIECE_HOLDER = preload("res://Scenes/piece_holder.tscn")
const MOVE_DOT_HOLDER = preload("res://Scenes/move_dot_holder.tscn")

const BLACK_KING : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/black_king.png")
const BLACK_QUEEN : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/black_queen.png")
const BLACK_BISHOP : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/black_bishop.png")
const BLACK_KNIGHT : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/black_knight.png")
const BLACK_ROOK : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/black_rook.png")
const BLACK_PAWN : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/black_pawn.png")

const WHITE_KING : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/white_king.png")
const WHITE_QUEEN : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/white_queen.png")
const WHITE_BISHOP : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/white_bishop.png")
const WHITE_KNIGHT : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/white_knight.png")
const WHITE_ROOK : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/white_rook.png")
const WHITE_PAWN : CompressedTexture2D = preload("res://Sprites/Chess/Pieces/white_pawn.png")


@onready var pieces: Node2D = $Pieces
@onready var dots: Node2D = $Dots
@onready var turn_sprite: Sprite2D = $Turn/TurnLabel/TurnSprite
@onready var win_label : Label = $Winner/WinLabel
@onready var win_sprite : Sprite2D = $Winner/WinLabel/WinnerSprite

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

@export var board : Array
@export var white : bool = true

var moves = []
var selected_piece : Vector2i = Vector2i(-1, -1)
var piece_nodes = []

var check : bool = false

var previous_board : Array = []

var OtherGame : int
var MyGameId : int = 1

func _ready() -> void:

	add_to_group("chess_board")

	turn_sprite.texture = WHITE_PAWN

	for y in range(8):
		piece_nodes.append([])
		for x in range(8):
			piece_nodes[y].append(null)

	# ONLY HOST CREATES BOARD
	if multiplayer.is_server():

		board = []

		setup_board()
	
	OtherGame = find_other_game()

func find_other_game():
	# Get the game manager
	var GameManager = get_tree().get_nodes_in_group("GameManager")[0]
	
	# Check for other game
	if GameManager:
		if GameManager.games[0] == MyGameId:
			return GameManager.games[1]
		elif GameManager.games[1] == MyGameId:
			return GameManager.games[0]

func _process(delta):
	
	if white:
		turn_sprite.texture = WHITE_PAWN;
	else:
		turn_sprite.texture = BLACK_PAWN;
		
	if board != previous_board:

		previous_board = board.duplicate(true)

		redraw_board()

func is_white_player() -> bool:
	return multiplayer.get_unique_id() == 1

func is_black_player() -> bool:
	return multiplayer.get_unique_id() != 1

@rpc("any_peer", "call_local")
func request_move(from_x, from_y, to_x, to_y):

	if not multiplayer.is_server():
		return

	var sender = multiplayer.get_remote_sender_id()

	if sender == 0:
		sender = 1

	if white and sender != 1:
		return

	if not white and sender == 1:
		return

	selected_piece = Vector2i(from_x, from_y)

	var piece = board[from_y][from_x]

	var legal_moves = get_legal_moves(piece, from_x, from_y)

	if Vector2i(to_x, to_y) in legal_moves:

		move_selected(to_x, to_y)
		var snapshot = board.duplicate(true)
		sync_board.rpc(snapshot)

@rpc("authority", "call_local", "reliable")
func sync_board(new_board):
	board = new_board.duplicate(true)
	clear_dots()
	redraw_board()
	

func set_selected_piece(x, y):
	var piece = board[y][x]

	if piece == 0:
		return
		
	if piece > 0 and not is_white_player():
		return

	if piece < 0 and not is_black_player():
		return
		
	selected_piece = Vector2i(x, y)
	print("Selected piece at:", selected_piece)
	
	clear_dots()
	
	state = true;
	show_options();

func show_options():
	moves = get_moves()

	print(moves)

	if moves == []:
		state = false
		return

	show_dots()
		
func get_moves() -> Array:
	var x = selected_piece.x
	var y = selected_piece.y

	var piece = board[y][x]

	return get_legal_moves(piece, x, y)
	
func get_piece_moves(piece, x, y) -> Array:
	match abs(piece):
		1:
			return get_pawn_moves(piece, x, y)
		2:
			return get_knight_moves(piece, x, y)
		3:
			return get_bishop_moves(piece, x, y)
		4:
			return get_rook_moves(piece, x, y)
		5:
			return get_queen_moves(piece, x, y)
		6:
			return get_king_moves(piece, x, y)

	return []

func show_dots():
	clear_dots()

	for move in moves:
		# Create new move dot at the valid move location
		var new_dot = MOVE_DOT_HOLDER.instantiate()
		dots.add_child(new_dot)
		
		new_dot.scale = MOVE_DOT_SIZE
		
		new_dot.position = Vector2(
			BOARD_BORDER + move.x * CELL_SIZE + CELL_SIZE / 2.0,
			BOARD_BORDER + move.y * CELL_SIZE + CELL_SIZE / 2.0
		)
		
		# Set position variables for moving
		new_dot.board_x = move.x
		new_dot.board_y = move.y

func clear_dots():
	for child in dots.get_children():
		child.queue_free()
		
func move_selected(board_x, board_y):

	var from_x = selected_piece.x
	var from_y = selected_piece.y

	var piece = board[from_y][from_x]

	# Update board data
	board[board_y][board_x] = piece
	board[from_y][from_x] = 0

	# Get visual node
	var piece_node = piece_nodes[from_y][from_x]

	# Remove captured piece
	if piece_nodes[board_y][board_x]:
		piece_nodes[board_y][board_x].queue_free()

	# Update node array
	piece_nodes[board_y][board_x] = piece_node
	piece_nodes[from_y][from_x] = null
	
	# Move visual
	piece_node.position = Vector2(
		BOARD_BORDER + board_x * CELL_SIZE + CELL_SIZE / 2.0,
		BOARD_BORDER + board_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	
	# Update stored coordinates
	piece_node.board_x = board_x
	piece_node.board_y = board_y
	
	selected_piece = Vector2i(-1, -1)
	
	var white_king = find_king(true)
	var black_king = find_king(false)
	
	print("White king is at: ", white_king)
	print("Black king is at: ", black_king)
	
	if is_in_check(true):
		if is_checkmate(true):
			print("White is defeated!")
			win_label.show()
			win_sprite.texture = BLACK_PAWN
		else:
			print("White is in check!")

	if is_in_check(false):
		if is_checkmate(false):
			print("Black is defated!")
			win_label.show()
			win_sprite.texture = WHITE_PAWN
		else:
			print("Black is in check")
	
	if white:
		white = false;
		turn_sprite.texture = BLACK_PAWN;
		print("Black's turn")
	else:
		white = true;
		turn_sprite.texture = WHITE_PAWN;
		print("White's turn")

func setup_board():
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([4, 2, 3, 5, 6, 3, 2, 4])

	redraw_board()

func redraw_board():

	clear_pieces()

	# Reset piece node tracking
	piece_nodes = []

	for y in range(BOARD_SIZE):

		piece_nodes.append([])

		for x in range(BOARD_SIZE):

			piece_nodes[y].append(null)

			# Skip empty squares
			if board[y][x] == 0:
				continue

			create_piece_visual(x, y)
			
func create_piece_visual(x, y):

	var new_piece = PIECE_HOLDER.instantiate()

	pieces.add_child(new_piece)

	# Track node
	piece_nodes[y][x] = new_piece

	# Coordinates
	new_piece.board_x = x
	new_piece.board_y = y

	# Position
	new_piece.position = Vector2(
		BOARD_BORDER + x * CELL_SIZE + CELL_SIZE / 2.0,
		BOARD_BORDER + y * CELL_SIZE + CELL_SIZE / 2.0
	)

	new_piece.scale = PIECE_SIZE

	var value = board[y][x]

	# Color ownership
	new_piece.is_white = value > 0

	# Texture
	match value:
		-6: new_piece.texture = BLACK_KING
		-5: new_piece.texture = BLACK_QUEEN
		-4: new_piece.texture = BLACK_ROOK
		-3: new_piece.texture = BLACK_BISHOP
		-2: new_piece.texture = BLACK_KNIGHT
		-1: new_piece.texture = BLACK_PAWN

		6: new_piece.texture = WHITE_KING
		5: new_piece.texture = WHITE_QUEEN
		4: new_piece.texture = WHITE_ROOK
		3: new_piece.texture = WHITE_BISHOP
		2: new_piece.texture = WHITE_KNIGHT
		1: new_piece.texture = WHITE_PAWN


func clear_pieces():
	for child in pieces.get_children():
		child.queue_free()

# Helpers for moves
func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8
func get_piece(pos: Vector2i):
	return board[pos.y][pos.x]
func is_empty(pos: Vector2i) -> bool:
	return get_piece(pos) == 0
func is_enemy(piece, target) -> bool:
	return (piece > 0 and target < 0) or (piece < 0 and target > 0)
	
func find_king(is_white: bool) -> Vector2i:
	var king_value = 6 if is_white else -6

	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			if board[y][x] == king_value:
				return Vector2i(x, y)

	return Vector2i(-1, -1) #Error 404: king not found, the kingdom is in shambles :p
	
func is_in_check(is_white: bool) -> bool:
	var king_pos = find_king(is_white)
	
	# Loop through every piece on the board
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var piece = board[y][x]

			if piece == 0:
				continue

			# Only look at enemy pieces
			if is_white and piece > 0:
				continue

			if not is_white and piece < 0:
				continue

			# Get enemy moves
			var enemy_moves : Array = []
			
			if abs(piece) == 1:
				enemy_moves = get_pawn_attacks(piece, x, y)
			else:
				enemy_moves = get_piece_moves(piece, x, y)

			# Can this piece attack the king?
			if king_pos in enemy_moves:
				return true

	return false

func is_checkmate(is_white: bool) -> bool:

	# If not in check, cannot be checkmate
	if not is_in_check(is_white):
		return false

	# Look through every piece
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):

			var piece = board[y][x]

			if piece == 0:
				continue

			# Only check current side's pieces
			if is_white and piece < 0:
				continue

			if not is_white and piece > 0:
				continue

			# If ANY legal move exists, not mate
			var legal_moves = get_legal_moves(piece, x, y)

			if legal_moves.size() > 0:
				return false

	# No legal moves and king is checked
	return true
	
func get_legal_moves(piece, from_x, from_y) -> Array:
	var legal_moves = []

	# Get normal moves first
	var possible_moves = get_piece_moves(piece, from_x, from_y)

	for move in possible_moves:

		# Save board state
		var captured_piece = board[move.y][move.x]

		# Simulate move
		board[move.y][move.x] = piece
		board[from_y][from_x] = 0

		# Check if own king is safe
		var still_safe = not is_in_check(piece > 0)

		# Undo move
		board[from_y][from_x] = piece
		board[move.y][move.x] = captured_piece

		# Keep only legal moves
		if still_safe:
			legal_moves.append(move)

	return legal_moves

func get_pawn_moves(piece, x, y):
	moves = []
	var pos = Vector2i(x, y)
	var dir = Vector2i(0, -1 if piece > 0 else 1)

	# forward 1
	var one_step = pos + dir
	if in_bounds(one_step) and is_empty(one_step):
		moves.append(one_step)

		# forward 2
		var start_row = 6 if piece > 0 else 1
		var two_step = pos + dir * 2

		if y == start_row and is_empty(two_step):
			moves.append(two_step)

	# captures
	for dx in [-1, 1]:
		var diag = pos + Vector2i(dx, dir.y)

		if in_bounds(diag):
			var target = get_piece(diag)
			if target != 0 and is_enemy(piece, target):
				moves.append(diag)

	return moves

func get_pawn_attacks(piece, x, y):
	var attacks = []

	var dir = -1 if piece > 0 else 1

	for dx in [-1, 1]:
		var pos = Vector2i(x + dx, y + dir)

		if in_bounds(pos):
			attacks.append(pos)

	return attacks

func get_rook_moves(piece, x, y):
	moves = []
	var start = Vector2i(x, y)

	var directions = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir in directions:
		var pos = start + dir

		while in_bounds(pos):
			var target = get_piece(pos)

			if target == 0:
				moves.append(pos)
			elif is_enemy(piece, target):
				moves.append(pos)
				break
			else:
				break

			pos += dir

	return moves
	
func get_bishop_moves(piece, x, y):
	moves = []
	var start = Vector2i(x, y)

	var directions = [
		Vector2i(1, 1),
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1)
	]

	for dir in directions:
		var pos = start + dir

		while in_bounds(pos):
			var target = get_piece(pos)

			if target == 0:
				moves.append(pos)
			elif is_enemy(piece, target):
				moves.append(pos)
				break
			else:
				break

			pos += dir

	return moves
	
func get_knight_moves(piece, x, y):
	moves = []
	var start = Vector2i(x, y)

	var directions = [
		Vector2i(1, 2),
		Vector2i(2, 1),
		Vector2i(2, -1),
		Vector2i(1, -2),
		Vector2i(-1, -2),
		Vector2i(-2, -1),
		Vector2i(-2, 1),
		Vector2i(-1, 2)
	]

	for dir in directions:
		var pos = start + dir

		if not in_bounds(pos):
			continue

		var target = get_piece(pos)

		if target == 0 or is_enemy(piece, target):
			moves.append(pos)

	return moves
	
func get_queen_moves(piece, x, y):
	moves = []
	var start = Vector2i(x, y)

	var directions = [
		Vector2i(1, 1),
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir in directions:
		var pos = start + dir

		while in_bounds(pos):
			var target = get_piece(pos)

			if target == 0:
				moves.append(pos)
			elif is_enemy(piece, target):
				moves.append(pos)
				break
			else:
				break

			pos += dir

	return moves

func get_king_moves(piece, x, y):
	moves = []
	var start = Vector2i(x, y)

	var directions = [
		Vector2i(1, 1),
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	for dir in directions:
		var pos = start + dir

		if not in_bounds(pos):
			continue

		var target = get_piece(pos)

		if target == 0 or is_enemy(piece, target):
			moves.append(pos)

	return moves
