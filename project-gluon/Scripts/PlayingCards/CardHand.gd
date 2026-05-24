extends HBoxContainer

const PlayingCard = preload("res://Scenes/PlayingCard.tscn")

var player_hands := {}

@onready var card_hand: HBoxContainer = self

var hand: Array = []

#### Creating cards ####

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)

		var host_id = multiplayer.get_unique_id()
		give_cards(host_id, 3)

func _on_peer_connected(id: int) -> void:
	print("Peer joined:" , id)

	player_hands[id] = []
	give_cards(id, 3)
	
func give_cards(peer_id: int, amount: int) -> void:
	if !player_hands.has(peer_id):
		player_hands[peer_id] = []

	# already dealt
	if player_hands[peer_id].size() > 0:
		return

	for i in amount:
		var card := randi_range(1, 14)

		player_hands[peer_id].append(card)
		rpc_id(peer_id, "receive_card", card)

func add_card(id, card_type):
	if !player_hands.has(id):
		player_hands[id] = []

	player_hands[id].append(card_type)
	rpc_id(id, "receive_card", card_type)


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
	print("Player ", player_id, " played ", card_type)

	# only redraw your own hand
	if player_id == multiplayer.get_unique_id():
		update_cards(player_id)


func player_has_card(id, card_type) -> bool:
	return (
		player_hands.has(id) and card_type in player_hands[id]
	)


func remove_card_from_hand(id, card_type) -> void:
	if player_hands.has(id):
		player_hands[id].erase(card_type)


func apply_card(id, card_type) -> void:
	print("Player ", id, " played card: ", card_type)


func update_cards(id):
	# clear cards
	for n in get_children():
		n.queue_free()
	
	# add remaining ones back
	for card in player_hands[id]:
		create_card(card)
	
