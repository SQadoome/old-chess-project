class_name GameHandler
extends Node2D

@onready var WhiteMap: TileMapLayer = get_node("CanvasLayer/WhitePieces")
@onready var BlackMap: TileMapLayer = get_node("CanvasLayer/BlackPieces")
@onready var ObstacleMap: TileMapLayer = get_node("CanvasLayer/Obstacles")
@onready var Overlay = load("res://scenes/overlay.tscn")
@onready var CastleOverlay = load("res://scenes/castle_overlay.tscn")
@onready var NETWORK: Network = get_tree().get_first_node_in_group("Network")


var pieces: Array = []
var player_team: int = 0
var selected_piece: Node2D
var BoardSize: int = 8
var Turn: int = 0
var Coins: int = 5



func _ready() -> void:
	if player_team == 1:
		$CanvasLayer/Board.scale.y = -1
		$CanvasLayer/WhitePieces.scale.y = -1
		$CanvasLayer/BlackPieces.scale.y = -1
	
	$CanvasLayer/p1inv._set_team(0)
	$CanvasLayer/p2inv._set_team(1)
	
	
	if player_team == 1:
		$CanvasLayer/p1inv.name = "Player2Inv"
		$CanvasLayer/p2inv.name = "Player1Inv"
	
	if player_team == 0:
		$CanvasLayer/p1inv.name = "Player1Inv"
		$CanvasLayer/p2inv.name = "Player2Inv"
	
	

@rpc("any_peer", "call_local", "reliable")
func _remove_item(node_name: String, caller_team: int) -> void:
	if caller_team == 0:
		$CanvasLayer/Player1Inv._remove_item(node_name)
	else:
		$CanvasLayer/Player2Inv._remove_item(node_name)
	

func _display_usernames(p1: String, p2: String) -> void:
	for i in 7:
		p1 = p1.left(p1.length()-1)
	for i in 9:
		p2 = p2.left(p2.length()-1)
	# getting rid of (HOST) or (PLAYER)
	if player_team == 0:
		$Fixed/MainPlayer.text = p1
		$Fixed/SecondaryPlayer.text = p2
	if player_team == 1:
		$Fixed/MainPlayer.text = p2
		$Fixed/SecondaryPlayer.text = p1
	


func _on_piece_moved() -> void:
	_change_turn.rpc()
	

func _get_team(piece: Node2D) -> int:
	for i in WhiteMap.get_children():
		if i == piece: return 0
	for i in BlackMap.get_children():
		if i == piece: return 1
	return 0
	


func _place_overlay(piece_node: Node2D, target_position: Vector2, type: int):
	var cell = ObstacleMap.local_to_map(target_position)
	if cell.x < -4 or cell.x > 3:
		return
	if cell.y < -4 or cell.y > 3:
		return
	var new_overlay
	if type == 0:
		new_overlay = Overlay.instantiate()
		new_overlay._set_piece(piece_node)
	if type == 1:
		new_overlay = CastleOverlay.instantiate()
		new_overlay._set_rook(piece_node)
	$CanvasLayer/Overlays.add_child(new_overlay)
	new_overlay.global_position = target_position
	if type == 1:
		return new_overlay
	


func _set_obstacle(target: Vector2) -> void:
	var cell = ObstacleMap.local_to_map(target)
	ObstacleMap.set_cell(cell, 0, Vector2(0, 0))
	

func _clear_overlays() -> void:
	for i in get_node("CanvasLayer/Overlays").get_children():
		i.queue_free()
	

func _check_for_king() -> void:
	if player_team == 0:
		for i in WhiteMap.get_children():
			i._look_for_checks()
	if player_team == 1:
		for i in BlackMap.get_children():
			i._look_for_checks()
	

@rpc("any_peer", "call_local", "reliable")
func _check_found(caller_team: int) -> void:
	_get_king(caller_team)._check()
	

func _move_piece(at_position: Vector2, piece: Node2D) -> void:
	var move_cords = ObstacleMap.local_to_map(at_position) - ObstacleMap.local_to_map(selected_piece.global_position)
	selected_piece._move(move_cords*22)
	piece._move.rpc(move_cords*22*Vector2i(1, -1))
	await get_tree().create_timer(0.25).timeout
	_change_turn.rpc()
	

func _castle(king, rook, king_target, rook_target) -> void:
	king._move(king_target)
	rook._move(rook_target)
	king._move.rpc(king_target)
	rook._move.rpc(rook_target)
	await get_tree().create_timer(0.25).timeout
	_change_turn.rpc()
	

func _find_piece(target: Vector2):
	for i in WhiteMap.get_children():
		if i.global_position == target:
			return i
	for i in BlackMap.get_children():
		if i.global_position == target:
			return i
	


@rpc("any_peer", "call_local", "reliable")
func _change_turn() -> void:
	if Turn == 1:
		Turn = 0
	else:
		Turn = 1
	if player_team == Turn:
		if player_team == 0:
			for i in WhiteMap.get_children():
				i.set_process_unhandled_input(true)
		if player_team == 1:
			for i in BlackMap.get_children():
				i.set_process_unhandled_input(true)
		_your_turn()
	else:
		if player_team == 0:
			for i in WhiteMap.get_children():
				i.set_process_unhandled_input(false)
		if player_team == 1:
			for i in BlackMap.get_children():
				i.set_process_unhandled_input(false)
	

func _your_turn() -> void:
	$Fixed/AnimationPlayer.play("turn")
	


func _get_king(team: int) -> Node2D:
	if team == 1:
		for i in BlackMap.get_children():
			if i.Type == "king":
				return i
	if team == 0:
		for i in WhiteMap.get_children():
			if i.Type == "king":
				return i
	
	return null
	


func _check_obstacles(at_position: Vector2):
	pieces.clear()
	for i in WhiteMap.get_children():
		pieces.append(i)
	for i in BlackMap.get_children():
		pieces.append(i)
	var cell = ObstacleMap.local_to_map(at_position)
	if ObstacleMap.get_cell_source_id(cell) == -1:
		return null
	else:
		for i in pieces:
			if i.global_position == at_position:
				return i
	

func _update_obstacle(old_position: Vector2, new_position: Vector2) -> void:
	ObstacleMap.erase_cell(ObstacleMap.local_to_map(old_position))
	ObstacleMap.set_cell(ObstacleMap.local_to_map(new_position), 0, Vector2(0, 0))
	


func _play_particle(particle_path: String, at_position: Vector2) -> void:
	var new_particle = load(particle_path).instantiate()
	get_node("CanvasLayer").add_child(new_particle)
	new_particle.global_position = at_position
	new_particle.finished.connect(_on_custom_particle_finished.bind(new_particle))
	new_particle.emitting = true

@rpc("any_peer", "call_local", "reliable")
func _add_piece(file_path: String, team: int, at_position: Vector2) -> void:
	var cell = ObstacleMap.local_to_map(at_position)
	var new_piece = load(file_path).instantiate()
	new_piece.global_position = ObstacleMap.map_to_local(cell)
	if team == 0:
		WhiteMap.add_child(new_piece)
	else:
		BlackMap.add_child(new_piece)
		
	new_piece.name = str(1)
	_get_king(0)._un_check()
	_get_king(1)._un_check()
	_check_for_king()
	

func _remove_obstacle(obstacle: Node2D) -> void:
	_erase_obstacle(obstacle.global_position)
	

func _erase_obstacle(at_position) -> void:
	ObstacleMap.erase_cell(ObstacleMap.local_to_map(at_position))
	

@rpc("any_peer", "call_local", "reliable")
func _add_bomb(file_path: String, at_position: Vector2, team: int) -> void:
	var new_bomb = load(file_path).instantiate()
	var cell = ObstacleMap.local_to_map(at_position)
	new_bomb.global_position = ObstacleMap.map_to_local(cell)
	if player_team == 1:
		new_bomb.global_position.y *= -1
	
	$CanvasLayer.add_child(new_bomb)
	new_bomb.Placed = true
	new_bomb._set_type("bomb")
	new_bomb._set_team(team)
	
	ObstacleMap.set_cell(cell, 0, Vector2.ZERO)
	


func _on_custom_particle_finished(particle_node: GPUParticles2D) -> void:
	particle_node.queue_free()
	


func _play_audio(file_name: String, strength: int) -> void:
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	new_player.volume_db = strength
	new_player.stream = load(file_name)
	new_player.finished.connect(_on_custom_audio_finished.bind(new_player))
	new_player.play()
	

func _on_custom_audio_finished(audio_player: AudioStreamPlayer) -> void:
	audio_player.queue_free()
	

func _increase_coins(value: int, caller_team: int) -> void:
	if caller_team == player_team:
		Coins += value
		NETWORK.Players["Player" + str(caller_team+1)]["Coins"] = Coins
		_update_coins.rpc(caller_team, Coins)
	

@rpc("any_peer", "call_local", "reliable")
func _update_coins(team: int, new_value: int) -> void:
	if player_team == team:
		$Fixed/GUI._update_coins("1", new_value)
	else:
		$Fixed/GUI._update_coins("2", new_value)
	_play_audio("res://audio/coin_grap.mp3", -20)
	

func _coin_animation(at_pos: Vector2, team:int, amount: int) -> void:
	for i in amount:
		var new_coin = load("res://scenes/coin.tscn").instantiate()
		new_coin.position = at_pos
		$CanvasLayer/Coins.add_child(new_coin)
		if player_team == team:
			new_coin._follow_target(get_node("CanvasLayer/0").global_position)
		else:
			new_coin._follow_target(get_node("CanvasLayer/1").global_position)
	

func _decrease_coins(caller_team, value: int) -> void:
	if caller_team == player_team:
		Coins -= value
		NETWORK.Players["Player" + str(caller_team+1)]["Coins"] = Coins
		_update_coins.rpc(caller_team, Coins)
	


func _check_mate(loser_team: int, winner_team: int) -> void:
	$Fixed/Turn.visible = false
	var king = _get_king(loser_team)
	king._death()
	get_node("CanvasLayer/BlackFocus").visible = true
	get_node("CanvasLayer/BlackFocus").global_position = king.global_position
	await get_tree().create_timer(1.5).timeout
	get_node("CanvasLayer/BlackFocus").visible = false
	for i in WhiteMap.get_children():
		i.set_process_unhandled_input(false)
	for i in BlackMap.get_children():
		i.set_process_unhandled_input(false)
	
	var new_trophy = load("res://scenes/trophy.tscn").instantiate()
	$CanvasLayer.add_child(new_trophy)
	new_trophy.global_position = king.global_position
	new_trophy._set_image(winner_team)
	

func _ask_to_place(target: Vector2) -> bool:
	var cell = ObstacleMap.local_to_map(target)
	if ObstacleMap.get_cell_source_id(cell) == -1:
		$CanvasLayer/Marker.visible = true
		$CanvasLayer/Marker.global_position = ObstacleMap.map_to_local(cell)
		
		if cell.x < -4 or cell.x > 3:
			$CanvasLayer/Marker.visible = false
			return false
		if cell.y < -4 or cell.y > 3:
			$CanvasLayer/Marker.visible = false
			return false
		
		return true
	else:
		$CanvasLayer/Marker.visible = false
		return false
	


@rpc("any_peer", "call_local", "reliable")
func _update_inventory(item_type: String, file_path: String, player: int, price: int) -> void:
	if player == 0:
		_decrease_coins(player, price)
		$CanvasLayer/Player1Inv._add_item(item_type, file_path, player)
	else:
		_decrease_coins(player, price)
		$CanvasLayer/Player2Inv._add_item(item_type, file_path, player)
	

func _ask_to_buy(price: int) -> bool:
	if Coins - price >= 0:
		if player_team == 0 and $CanvasLayer/Player1Inv._ask_to_add():
			return true
		if player_team == 1 and $CanvasLayer/Player2Inv._ask_to_add():
			return true
	return false
	


func _ask_to_refresh(price: int) -> bool:
	if Coins - price >= 0:
		return true
	else:
		return false
	

@rpc("any_peer", "call_local", "reliable")
func _refresh(price: int, team: int) -> void:
	_decrease_coins(team, price)
	

var rematch_count: int = 0
func _show_rematch() -> void:
	$Fixed/Rematch.show()
	$Fixed/Quit.show()
	

var RematchCount: int = 0
func _on_quit_pressed() -> void:
	_cancel_rematch.rpc()
	get_tree().quit()
	

@rpc("any_peer", "reliable")
func _cancel_rematch() -> void:
	$Fixed/Rematch/Label.text = "DECLINED"
	


func _on_rematch_pressed() -> void:
	_update_rematch.rpc()
	

@rpc("any_peer", "call_local", "reliable")
func _update_rematch() -> void:
	RematchCount += 1
	$Fixed/Rematch/Label.text = str(RematchCount) + "/2"
	print(RematchCount)
	if RematchCount == 2:
		print("HA)FW")
		_restart_game()
	

func _restart_game() -> void:
	$Fixed/Rematch.hide()
	$Fixed/Quit.hide()
	RematchCount = 0
	$Fixed/Rematch/Label.text = str(RematchCount) + "0/2"
	$Fixed/Turn.visible = true
	Coins = 5
	$Fixed/GUI/P1Coins.text = "        5"
	$Fixed/GUI/P2Coins.text = "        5"
	
	$CanvasLayer/Player1Inv._clear_items()
	$CanvasLayer/Player2Inv._clear_items()
	
	$Fixed/Shop._reset_shop()
	get_tree().get_first_node_in_group("Trophy").queue_free()
	
	$CanvasLayer/WhitePieces.queue_free()
	$CanvasLayer/BlackPieces.queue_free()
	
	var white_pieces = load("res://scenes/white_pieces.tscn").instantiate()
	WhiteMap = white_pieces
	white_pieces.name = "WhitePieces"
	$CanvasLayer.add_child(white_pieces)
	
	var black_pieces = load("res://scenes/black_pieces.tscn").instantiate()
	BlackMap = black_pieces
	black_pieces.name = "BlackPieces"
	$CanvasLayer.add_child(black_pieces)
	
	for i in get_tree().get_nodes_in_group("Bomb"):
		i.queue_free()
	
	Turn == 0
	ObstacleMap.clear()
	if player_team == 1:
		black_pieces.scale.y = -1
		white_pieces.scale.y = -1
	
