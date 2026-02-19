class_name Piece
extends Node2D

@onready var game_handler = get_tree().get_first_node_in_group("GameHandler")

signal moved

var CurrentTeam: int
var Moves: Dictionary = {
	
}
var Type: String
var MouseIn: bool = false
var CollidedPiece: Node2D

enum states{
	idle, moving
}
var current_state = states.idle
var TargetPiece: Node2D
var CoinValue: int

func _unhandled_input(event: InputEvent) -> void:
	if current_state == states.idle and game_handler.Turn == CurrentTeam:
		if event.is_action_pressed("left_click") and MouseIn:
			if game_handler.selected_piece != null and game_handler.selected_piece != self:
				game_handler.selected_piece._un_select()
			_select()
			_show_moves()
		if event.is_action_pressed("right_click") and game_handler.selected_piece != null:
			game_handler.selected_piece._un_select()
			game_handler._play_audio("res://audio/cancel.mp3", -15)
	


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Piece"):
		if area.get_parent().Type == "king":
			game_handler._check_mate(area.get_parent().CurrentTeam, CurrentTeam)
			self.hide()
		else:
			game_handler._play_particle("res://scenes/eat_particles.tscn", global_position)
			randomize()
			_eat(area.get_parent())
			game_handler._play_audio("res://audio/eat_" + str(randi_range(1, 2)) + ".mp3", -20)
			game_handler._clear_overlays()
	if area.get_parent().is_in_group("Overlay"):
		if area.get_parent().HeldPiece.CurrentTeam != CurrentTeam:
			_set_frame(2)
	

func _process(delta: float) -> void:
	if game_handler.Turn == CurrentTeam:
		get_node("Area2D").monitoring = false
	else:
		get_node("Area2D").monitoring = true
	

func _eat(piece: Node2D) -> void:
	game_handler._coin_animation(piece.global_position, CurrentTeam, CoinValue)
	var coin_increase = piece.CoinValue
	piece.queue_free()
	await get_tree().create_timer(0.5).timeout
	game_handler._increase_coins(coin_increase, CurrentTeam)
	

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Overlay"):
		if area.get_parent().HeldPiece.CurrentTeam != CurrentTeam:
			_set_frame(0)


func _on_mouse_entered() -> void:
	if game_handler.player_team == CurrentTeam:
		MouseIn = true
	

func _on_mouse_exited() -> void:
	if game_handler.player_team == CurrentTeam:
		MouseIn = false
	

func _select() -> void:
	game_handler.selected_piece = self
	game_handler._play_audio("res://audio/select.mp3", -15)
	_set_frame(1)
	

func _un_select() -> void:
	game_handler.selected_piece = null
	game_handler._clear_overlays()
	_set_frame(0)
	

func _set_team() -> void:
	CurrentTeam = game_handler._get_team(self)
	game_handler._set_obstacle(global_position)
	if CurrentTeam == 0:
		_change_sprite("res://art/normal/white_" + Type + ".png")
	if CurrentTeam == 1:
		_change_sprite("res://art/normal/black_" + Type + ".png")
		scale.y = -1
	

func _show_moves() -> void:
	game_handler._clear_overlays()
	for i in Moves:
		if Moves[i]["Type"] < 2:
			_single_tile_move(i)
		elif Moves[i]["Type"] == 2:
			_straight_tiles_moves(i)
		elif Moves[i]["Type"] == 3:
			_single_capturable_tile_move(i)
		if Moves[i]["Type"] == 10:
			_handle_castling()
	

func _handle_castling() -> void:
	_queen_side_castle()
	_king_side_castle()
	

func _queen_side_castle() -> void:
	var dir
	var target
	var obstacle
	var king_side = true
	for i in 4:
		dir = Vector2(-1, 0)
		target = dir*(i+1)*22 + global_position
		obstacle = game_handler._check_obstacles(target)
		if obstacle != null and (i+1) < 4:
			return
		if obstacle != null:
			if (i+1) == 4 and obstacle.Type == "rook":
				if obstacle.CanCastle == true:
					var at_position = (global_position + Vector2.LEFT*22*2)
					game_handler._place_overlay(obstacle, at_position, 1).Side = 0
	
	

func _king_side_castle() -> void:
	var dir
	var target
	var obstacle
	var king_side = true
	for i in 3:
		dir = Vector2(1, 0)
		target = dir*(i+1)*22 + global_position
		obstacle = game_handler._check_obstacles(target)
		if obstacle != null and (i+1) < 3:
			return
		if obstacle != null:
			if (i+1) == 3 and obstacle.Type == "rook":
				if obstacle.CanCastle == true:
					var at_position = (global_position + Vector2.RIGHT*22*2)
					game_handler._place_overlay(obstacle, at_position, 1).Side = 1
	

func _single_tile_move(piece_type: String):
	var target = Moves[piece_type]["Target"]+global_position
	if Moves[piece_type]["Type"] == 0 and game_handler._check_obstacles(target) == null:
		game_handler._place_overlay(self, target, 0)
	if Moves[piece_type]["Type"] == 1:
		var obstacle = game_handler._check_obstacles(target)
		if obstacle != null:
			game_handler._place_overlay(self, target, 0)
	

func _straight_tiles_moves(piece_type: String) -> void:
	var dir = Moves[piece_type]["Direction"]
	var obstacle
	for i in Moves[piece_type]["Limit"]:
		obstacle = game_handler._check_obstacles(dir*(i+1)*22+global_position)
		if obstacle == null:
			game_handler._place_overlay(self, dir*(i+1)*22+global_position, 0)
		if obstacle != null:
			if obstacle.CurrentTeam != CurrentTeam and Moves[piece_type]["CanCapture"]:
				game_handler._place_overlay(self, dir*(i+1)*22+global_position, 0)
			return
	

func _single_capturable_tile_move(piece_type: String) -> void:
	var target = Moves[piece_type]["Target"]+global_position
	var obstacle = game_handler._check_obstacles(target)
	if obstacle == null:
		game_handler._place_overlay(self, target, 0)
	else:
		if obstacle.CurrentTeam != CurrentTeam:
			game_handler._place_overlay(self, target, 0)
	

func _look_for_checks() -> void:
	var check_available = false
	var enemy_king
	if CurrentTeam == 0:
		enemy_king = game_handler._get_king(1)
	else:
		enemy_king = game_handler._get_king(0)
	for i in _theorize_moves():
		if i == enemy_king.global_position:
			check_available = true
	if check_available:
		game_handler._check_found.rpc(enemy_king.CurrentTeam)
		
	

func _theorize_moves() -> Array:
	var available_moves = []
	for i in Moves:
		if Moves[i]["Type"] == 1 or Moves[i]["Type"] == 3:
			available_moves.append(Moves[i]["Target"]+global_position)
		if Moves[i]["Type"] == 2:
			var obstacle
			var dir = Moves[i]["Direction"]
			var found_obstacle = false
			for count in Moves[i]["Limit"]:
				obstacle = game_handler._check_obstacles(dir*(count+1)*22+global_position)
				#print("piece: ", str(global_position), "///", "target: ", str(dir*i*22+global_position))
				if obstacle == null or obstacle.Type == "king":
					if not found_obstacle:
						available_moves.append(dir*(count+1)*22+global_position)
				else:
					found_obstacle = true
		
	return available_moves


@rpc("any_peer", "reliable")
func _move(target_cords: Vector2) -> void:
	game_handler._get_king(0)._un_check()
	game_handler._get_king(1)._un_check()
	game_handler._update_obstacle(global_position, target_cords+global_position)
	var new_tween = get_tree().create_tween()
	new_tween.finished.connect(_on_move_tween_finished.bind(new_tween, target_cords+global_position))
	new_tween.tween_property($Sprite2D, "global_position", target_cords+global_position, 0.3)
	_set_frame(0)
	emit_signal("moved")
	game_handler._play_audio("res://audio/move.mp3", -15)
	if game_handler.selected_piece != null:
		game_handler.selected_piece._un_select()
	current_state = states.moving
	

func _on_move_tween_finished(move_tween: Tween, target_position: Vector2) -> void:
	current_state = states.idle
	$Sprite2D.global_position = global_position
	global_position = target_position
	move_tween.kill()
	await get_tree().create_timer(0.05).timeout
	game_handler.call_deferred("_check_for_king")
	

func _set_frame(value: int) -> void:
	get_node("Sprite2D").frame = value
	

func _change_sprite(file_name: String) -> void:
	get_node("Sprite2D").texture = load(file_name)
	
