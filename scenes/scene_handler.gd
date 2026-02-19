extends Node2D

var player_1
var player_2

@rpc("authority", "call_local", "reliable")
func _start_game(p1, p2) -> void:
	player_1 = p1
	player_2 = p2
	var new_game = load("res://scenes/game_handler.tscn").instantiate()
	if multiplayer.is_server():
		new_game.player_team = 0
	else:
		new_game.player_team = 1
	get_node("CanvasLayer").queue_free()
	add_child(new_game)
	new_game._display_usernames(p1, p2)
	
