extends Control

# Textures
const DESERT : CompressedTexture2D = preload("res://Sprites/TerrainPieces/desert.png")
const PLAINS : CompressedTexture2D = preload("res://Sprites/TerrainPieces/plains.png")
const FOREST : CompressedTexture2D = preload("res://Sprites/TerrainPieces/forest.png")
const LAKE : CompressedTexture2D = preload("res://Sprites/TerrainPieces/lake.png")

@onready var piece_texture : TextureRect = $Sprite
@onready var piece_name : Label = $PieceName

var type : int = 0

var description_box : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	description_box = get_tree().get_first_node_in_group("TerrainInfoBox")

func update(piece_type: int) -> void:
	type = piece_type
	
	match abs(type):
		1:
			piece_name.text = "Plains"
			piece_texture.texture = PLAINS
		2: 
			piece_name.text = "Desert"
			piece_texture.texture = DESERT
		3: 
			piece_name.text = "Lake"
			piece_texture.texture = LAKE
		4:
			piece_name.text = "Forest"
			piece_texture.texture = FOREST

# On hover
func _on_button_mouse_entered() -> void:
	if description_box:
		
		description_box.visible = true
		
		match abs(type):
			1:
				description_box.text = "Plains: Acts as a normal space on the board."
			2:
				description_box.text = "Desert: If a piece is moved here, it must be moved out on the next turn, or it will die of dehydration."
			3:
				description_box.text = "Lake: Pieces cannot move through the lake, except bishops. They can walk on water."
			4:
				description_box.text = "Forests: Pieces here are hidden, and cannot be captured."


func _on_button_mouse_exited() -> void:
	description_box.visible = false
