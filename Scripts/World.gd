extends Node2D

func create_player(player_name: String) -> void:
	var player = preload("res://Scenes/Player.tscn").instance()
	var player_id = get_tree().get_network_unique_id()
	player.set_player_label(player_name)
	player.set_name(str(player_id))
	player.set_network_master(player_id)
	add_child(player)
	
func get_player() -> Object:
	return get_node(str(get_tree().get_network_unique_id()))
