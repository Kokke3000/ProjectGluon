extends Panel

@onready var label: Label = $CardSprite/CardNumber

func update(type) -> void:
	label.text = str(type)
