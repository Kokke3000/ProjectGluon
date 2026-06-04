extends Control

@onready var sprite : TextureRect = $Sprite
@onready var piece_name : Label = $PieceName

var type : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update(piece_type: int) -> void:
	type = piece_type
	
	match abs(type):
		1:
			piece_name.text = "Plains"
		2: 
			piece_name.text = "Desert"
		3: 
			piece_name.text = "Lake"
	
