class_name Network
extends Node2D

var peer: ENetMultiplayerPeer
var IP_ADDRESS: String
var PORT: int
var UserName: String = ""
var Players: Dictionary = {
	"Player1": {
		"Team": 0,
		"JoinOrder": 1,
		"Username": "",
		"Coins": 5
	},
	"Player2": {
		"Team": 0,
		"JoinOrder": 1,
		"Username": "",
		"Coins": 5
	}
}

signal player_joined(username: String, player_id: int, peer_id: int)
signal player_ready(value: bool, player_id: int)

func _ready() -> void:
	peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	

func _create_server(port, host_name):
	PORT = port
	
	UserName = host_name
	var error = peer.create_server(PORT, 5)
	if error != OK:
		print("Cannot host game: ", error)
		return
	multiplayer.set_multiplayer_peer(peer)
	_add_player(UserName, 1, 1)
	position_in_lobby += 1
	print("Server Started.")
	print("Host connected: 1")
	

func _create_client(ip, port, client_name):
	IP_ADDRESS = ip
	PORT = port
	
	UserName = client_name
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.set_multiplayer_peer(peer)
	



func _on_peer_connected(id: int):
	if not multiplayer.is_server(): return
	
	print("player connected: ", str(id))
	

func _on_connected_to_server():
	_ask_to_join_lobby.rpc_id(1, UserName)
	

var position_in_lobby = 1
@rpc("any_peer", "reliable")
func _ask_to_join_lobby(user_name):
	Players["Player" + str(position_in_lobby)]["Username"] = user_name
	#Players["Player" + str(position_in_lobby)]["JoinOrder"] = position_in_lobby
	#Players["Player" + str(position_in_lobby)]["Team"] = position_in_lobby - 1
	_add_player.rpc_id(multiplayer.get_remote_sender_id(), UserName, 1, 1)
	_add_player.rpc(user_name, position_in_lobby, multiplayer.get_remote_sender_id())
	position_in_lobby += 1
	

@rpc("call_local", "reliable")
func _add_player(player_name, id, peer_id):
	emit_signal("player_joined", player_name, id, peer_id)
	


# this function is called ONLY ON THE HOST when a PEER disconnects from it.
func _on_peer_disconnected(id: int):
	if not multiplayer.is_server(): return
	
	position_in_lobby -= 1
	print("player disconnected: ", str(id))
	

func _ask_leave_server():
	print("player tried to disconnect: ", str(peer.get_unique_id()))
	_leave_server.rpc(peer.get_unique_id())
	

@rpc('reliable', "call_local", 'any_peer')
func _leave_server(peer_id: int):
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.disconnect_peer(peer_id)
	
