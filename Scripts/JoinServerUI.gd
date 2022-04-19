extends Control

onready var player_name_line_edit: LineEdit = $Window/PlayerInfo/PlayerNameInfo/LineEdit
onready var server_host_line_edit: LineEdit = $Window/PlayerInfo/ServerHostInfo/LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connected_to_server", self, "queue_free")

func _on_JoinButton_pressed():
	var player_name: String = player_name_line_edit.get_text()
	var server_host_ip: String = server_host_line_edit.get_text()
	$"/root/Network".connect_to_server(player_name, server_host_ip)


func _on_ExitButton_pressed():
	queue_free()
