extends Node2D

const SPEED := 1000.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position

	if dir.length() > 1.0:
		global_position += dir.normalized() * SPEED * delta
