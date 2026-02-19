extends Placeable

var Placed: bool = false

func _set_type(new_type: String) -> void:
	item_type = new_type


func _unhandled_input(event: InputEvent) -> void:
	if not Placed:
		if event.is_action_pressed("left_click") and Selected:
			_place()
		if event.is_action_pressed("left_click") and MouseIn:
			if game_handler.player_team == game_handler.Turn:
				_select()
		if event.is_action_pressed("right_click"):
			_un_select()
	

func _on_mouse_entered() -> void:
	if team == game_handler.player_team and not Placed:
		get_node("Sprite2D").frame = 1
		MouseIn = true
	


func _on_mouse_exited() -> void:
	if team == game_handler.player_team and not Placed:
		get_node("Sprite2D").frame = 0
		MouseIn = false
	

func _place() -> void:
	if CanPlace:
		if team == 1:
			game_handler._add_bomb.rpc(("res://scenes/placeable_" + item_type + ".tscn"), global_position*Vector2(1, -1), team)
		else:
			game_handler._add_bomb.rpc(("res://scenes/placeable_" + item_type + ".tscn"), global_position, team)
		_un_select()
		game_handler._change_turn.rpc()
		game_handler._remove_item.rpc(get_parent().name, team)
		queue_free()
	


func _on_area_entered(area: Area2D) -> void:
	if Placed:
		if area.get_parent().is_in_group("Piece"):
			$AnimationPlayer.play("explode")
		if area.get_parent().is_in_group("Overlay"):
				get_node("Sprite2D").frame = 2


func _on_explosion_area_entered(area: Area2D) -> void:
	if Placed:
		if area.get_parent().is_in_group("Piece"):
			if area.get_parent().Type != "king":
				area.get_parent().queue_free()
				game_handler._remove_obstacle(area.get_parent())
			else:
				var loser_team = area.get_parent().CurrentTeam
				var winner_team
				if area.get_parent().CurrentTeam == 0:
					winner_team = 1
				else:
					winner_team = 0
				game_handler._check_mate(loser_team, winner_team)
	


func _on_area_exited(area: Area2D) -> void:
	if Placed:
		if area.get_parent().is_in_group("Overlay"):
			get_node("Sprite2D").frame = 0
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		queue_free()
	
