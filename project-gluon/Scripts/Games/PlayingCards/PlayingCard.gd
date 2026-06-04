extends Panel

@onready var card_number: Label = $CardSprite/CardNumber
@onready var card_effect: Label = $CardSprite/CardEffect

var card_type : int

func _ready() -> void:
	card_effect.visible = false
	
func update(type) -> void:
	card_number.text = str(type)
	card_type = type

	match abs(card_type):
		14:
			card_effect.text = "King: Crown a new pawn as king, the old king is usurped"
		13:
			card_effect.text = "Queen: Charm any enemy piece touching the queen"
		12:
			card_effect.text = "Jack: Knight a friendly pawn"
		1:
			card_effect.text = "Ace: In checkmate, play this card to send the king to a safe square" 
		2:
			card_effect.text = "Two: You may move two pawns this turn"
		3:
			card_effect.text = "Three: You may move a pawn backwards this turn"
		4:  
			card_effect.text = "Four: Designate a piece, it cannot be captured on the enemy's next turn"
		4:  
			card_effect.text = "Five: One of your non-knight pieces can move as a knight this turn"

## Chess ##
func _on_play_card_button_mouse_entered() -> void:
	card_effect.visible = true



func _on_play_card_button_mouse_exited() -> void:
	
	card_effect.visible = false
	card_effect.text = ""


func _on_play_card_button_pressed():
	self.get_parent().request_play_card.rpc_id(1, card_type)
