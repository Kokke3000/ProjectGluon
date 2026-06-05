extends Control

@onready var ip_input: LineEdit = $VBoxContainer/IpBox

var ip
func _on_server_pressed() -> void:
	NetworkHandler.start_server()

func _on_client_pressed() -> void:
	
	if ip_input.text != "":
		ip = ip_input.text
	else:
		ip = "localhost"

	NetworkHandler.start_client(ip)
