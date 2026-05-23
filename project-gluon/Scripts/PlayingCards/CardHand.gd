extends HBoxContainer

const PlayingCard = preload("res://Scenes/PlayingCard.tscn")

@onready var card_hand: HBoxContainer = $"."


var hand : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_card(3)

# Add a random card
func add_card(amount : int) -> void:
	while amount > 0:
		var card : int = randi_range(0, 13)
		hand.append(card)
		create_card(card)
		print("Added card: ", card)
		amount -= 1
	
	print(hand)

func create_card(type : int):
	var new_card = PlayingCard.instantiate()
	card_hand.add_child(new_card)
	new_card.update(type)
