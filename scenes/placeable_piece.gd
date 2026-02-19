extends Placeable


func _set_type(new_type: String) -> void:
	item_type = new_type
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and Selected:
		_place()
	if event.is_action_pressed("left_click") and MouseIn:
		if game_handler.player_team == game_handler.Turn:
			_select()
	if event.is_action_pressed("right_click"):
		_un_select()
	

func _on_mouse_entered() -> void:
	if team == game_handler.player_team:
		get_node("Sprite2D").frame = 1
		MouseIn = true
	


func _on_mouse_exited() -> void:
	if team == game_handler.player_team:
		get_node("Sprite2D").frame = 0
		MouseIn = false
	
func _place() -> void:
	if CanPlace:
		if game_handler.player_team == team and team == 1:
			game_handler._add_piece.rpc(("res://scenes/" + item_type + ".tscn"), team, global_position*Vector2(1, -1))
		else:
			game_handler._add_piece.rpc(("res://scenes/" + item_type + ".tscn"), team, global_position)
		_un_select()
		game_handler._change_turn.rpc()
		game_handler._remove_item.rpc(get_parent().name, team)
	
