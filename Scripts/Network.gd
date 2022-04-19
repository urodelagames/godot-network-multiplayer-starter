extends Node

# How I ran as a server on GCP:  nohup ./Godot_v3.2.1-stable_linux_server.64 --main-pack SquaresClub.pck --network_connection_type=server &
const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const DEFAULT_MAX_PLAYERS = 5
const DEFAULT_CONNECTION_TYPE = "client"
const SERVER_ID = 1

var players = {}
var my_data = {'name': null, 'transform': null}

func parse_os_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	return arguments
	
func _ready():
	# Network signals.
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	
	# Get arguments to check if this is the server.
	var args = parse_os_args()
	var network_connection_type = args.get('network_connection_type', DEFAULT_CONNECTION_TYPE)
	
	# Create the server if this code is ran the server.
	# And name the server "Server Host".
	if network_connection_type == 'server':
		create_server('Server Host')
		
# You're the server host and you create a server.
func create_server(server_host_name: String):
	my_data['name'] = server_host_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, DEFAULT_MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	players[SERVER_ID] = my_data

# Called when this client clicks "join",
# then the player connects to the server.
func connect_to_server(player_nickname: String, ip: String = DEFAULT_IP, port: int = DEFAULT_PORT):
	my_data['name'] = player_nickname
	
	print("%s connected." % player_nickname)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	
	get_tree().get_root().get_node('World').create_player(player_nickname)

# Called when THIS client successfully connects to the server.
func _on_connected_to_server():
	var my_player_id = get_tree().get_network_unique_id()
	players[my_player_id] = my_data
	
	# # Send all other clients (including server) to create this player on their screens.
	rpc('create_player', my_player_id, my_data)

# Notifies this client when ANOTHER player connects to the same server. 
# This also gets called for the server, but we don't do much with that. 
# 	In that case, other_player_id is 1 for the server.
func _on_player_connected(other_player_id):
	var player_id = get_tree().get_network_unique_id()
	
	# This client asks the server for the new player's data.
	if not(get_tree().is_network_server()):
		rpc_id(1, 'get_player_data', player_id, other_player_id)
	
# Notified this client when ANOTHER player disconnects from the same server.
func _on_player_disconnected(other_player_id):
	if players.has(other_player_id):
		players.erase(other_player_id)
		
		for child in get_tree().get_root().get_node("World").get_children():
			if child.get_name() == str(other_player_id):
				child.queue_free()

# This function is called on the server.
# Tells the calling_player_id to create the new player (aka requsted_about_player_id).
remote func get_player_data(calling_player_id, requested_about_player_id):
	if get_tree().is_network_server():
		rpc_id(calling_player_id, 'create_player', requested_about_player_id, players[requested_about_player_id])

# This function is called on this client.
# Create puppet player in this client's game.
remote func create_player(other_player_id, data):
	players[other_player_id] = data
	var new_player = load('res://Scenes/Player.tscn').instance()
	new_player.set_player_label(data["name"])
	new_player.set_name(str(other_player_id))
	new_player.set_network_master(other_player_id) # Tell this puppet player that it's being controlled by some other peer.
	get_tree().get_root().get_node('World').add_child(new_player)
	
# This function is called by this client.
# Tells the server to send this client's message to all other clients.
func send_message(message: String, player_id: int) -> void:
	rpc("receive_message", message, player_id)
	
# This function is called on all other clients.
# Create message for all other clients to see.
remote func receive_message(message: String, sent_from_player_id: int) -> void:
	get_tree().get_root().get_node('World').get_node(str(sent_from_player_id)).set_message_label(message)
