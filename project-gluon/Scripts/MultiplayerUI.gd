extends Control

@onready var ip_input: LineEdit = $VBoxContainer/LineEdit

func _on_server_pressed() -> void:
	NetworkHandler.start_server()

func _on_client_pressed() -> void:
	NetworkHandler.start_client()
