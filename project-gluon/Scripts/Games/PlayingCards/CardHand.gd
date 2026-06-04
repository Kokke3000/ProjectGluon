extends HBoxContainer

const PlayingCard = preload("res://Scenes/PlayingCard.tscn")

var player_hands := {}

@onready var card_hand: HBoxContainer = self

var hand : Array = []

# Game Id's
var MyGameId : int = 2
var OtherGame : int

# Chess variables
var ChessBoard
var white: bool

var GameManager

#### Creating cards ####

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		
	GameManager = get_tree().get_nodes_in_group("GameManager")[0]
	if GameManager.games.has(MyGameId):
		OtherGame = find_other_game()
	
	# Things required for combining with:
		# Chess:
	if OtherGame == 1:
		ChessBoard = get_tree().get_nodes_in_group("ChessBoard")[0]
		# Terrain pieces:
	

func find_other_game():
	# Check for other game
	if GameManager:
		if GameManager.games[0] == MyGameId:
			return GameManager.games[1]
		elif GameManager.games[1] == MyGameId:
			return GameManager.games[0]
		return null

func _process(delta) -> void:
	if OtherGame == 1 and ChessBoard:
		white = ChessBoard.white
		
# When client connects -> Deal both hands
func _on_peer_connected(player_id: int) -> void:
	print("Peer joined:" , player_id)
	
	# Deal client hand
	player_hands[player_id] = []
	give_cards(player_id, 3)
	
	# Deal host hand
	var host_id = 1
	give_cards(host_id, 3)
	
# Deals out starting cards
# Otherwise card giving handled by add_card
func give_cards(player_id: int, amount: int) -> void:
	if !player_hands.has(player_id):
		player_hands[player_id] = []
		print(player_hands[player_id])

	# already dealt
	if player_hands[player_id].size() > 0:
		return

	for i in amount:
		var card := randi_range(1, 14)

		player_hands[player_id].append(card)
		rpc_id(player_id, "receive_card", card)

func add_card(player_id, card_type):
	if !player_hands.has(player_id):
		player_hands[player_id] = []

	player_hands[player_id].append(card_type)
	rpc_id(player_id, "receive_card", card_type)


@rpc("authority", "call_local")
func receive_card(card: int) -> void:
	hand.append(card)
	create_card(card)


func create_card(type: int) -> void:
	var new_card = PlayingCard.instantiate()
	card_hand.add_child(new_card)
	new_card.update(type)

#### Playing cards ####

@rpc("any_peer", "call_local")
func request_play_card(card_type: int) -> void:
	if !multiplayer.is_server():
		return

	var sender := multiplayer.get_remote_sender_id()

	if !player_has_card(sender, card_type):
		print("Cheating caught from player: ", sender)
		print("Tried to play:", card_type)
		print("Has cards:", player_hands.get(sender, []))
		return

	remove_card_from_hand(sender, card_type)
	apply_card(sender, card_type)

	resolve_played_card.rpc(sender, card_type)


@rpc("authority", "call_local")
func resolve_played_card(player_id: int, card_type: int) -> void:
	# only redraw your own hand
	if player_id == multiplayer.get_unique_id():
		update_cards()
	
	if player_id == multiplayer.get_unique_id():
		hand.erase(card_type)
		update_cards()


func player_has_card(player_id, card_type) -> bool:
	return (
		player_hands.has(player_id) and card_type in player_hands[player_id]
	)

func remove_card_from_hand(player_id, card_type) -> void:
	if player_hands.has(player_id):
		player_hands[player_id].erase(card_type)

func update_cards():
	for child in get_children():
		child.queue_free()

	for card in hand:
		create_card(card)

func apply_card(player_id, card_type) -> void:
	print("Player ", player_id, " played card: ", card_type)
	
