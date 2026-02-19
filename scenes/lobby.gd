extends Control

@onready var Network: Node2D = get_tree().get_first_node_in_group("Network")

var PlayerId: int
var ReadyCount: int = 0


func _on_host_pressed() -> void:
	var port = int($VBoxContainer/HBoxContainer4/Port.text)
	var user_name = $VBoxContainer/HBoxContainer2/Username.text
	Network._create_server(port, user_name)
	get_node("VBoxContainer").queue_free()
	$PostServer.show()
	


func _on_join_pressed() -> void:
	var port = int($VBoxContainer/HBoxContainer4/Port.text)
	var ip = $VBoxContainer/HBoxContainer3/Ip.text
	var user_name = $VBoxContainer/HBoxContainer2/Username.text
	Network._create_client(ip, port, user_name)
	get_node("VBoxContainer").queue_free()
	$PostServer.show()
	


func _on_leave_pressed() -> void:
	Network._ask_leave_server()
	

func _on_network_player_joined(username: String, player_id: int, peer_id: int) -> void:
	if peer_id == 1:
		get_node("PostServer/Players/Label" + str(player_id)).text = username + "  (HOST)"
	else:
		get_node("PostServer/Players/Label" + str(player_id)).text = username + "   (PLAYER)"
	if multiplayer.get_unique_id() == peer_id:
		PlayerId = player_id
	



func _on_ready_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_ready_up.rpc(PlayerId)
	else:
		_ready_down.rpc(PlayerId)
	

@rpc("any_peer", "call_local")
func _ready_up(id):
	get_node("PostServer/ColorRect" + str(id)).modulate = Color(Color.GREEN)
	ReadyCount += 1
	
	if multiplayer.is_server():
		_check_ready()
	

func _check_ready():
	if ReadyCount >= 2:
		$PostServer/Start.show()
	else:
		$PostServer/Start.hide()
	

@rpc("any_peer", "call_local")
func _ready_down(id):
	get_node("PostServer/ColorRect" + str(id)).modulate = Color(Color.RED)
	ReadyCount -= 1
	
	if multiplayer.is_server():
		_check_ready()
	

func _on_network_player_ready(ready_value: bool, player_id: int) -> void:
	if ready_value:
		get_node("PostServer/ColorRect" + str(player_id)).modulate = Color(Color.GREEN)
	else:
		get_node("PostServer/ColorRect" + str(player_id)).modulate = Color(Color.RED)
	

func _on_start_pressed() -> void:
	get_parent().get_parent()._start_game.rpc($PostServer/Players/Label1.text, $PostServer/Players/Label2.text)
	
