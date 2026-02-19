extends Node2D

var HeldPiece: Node2D
var MouseIn: bool = false


func _set_piece(piece: Node2D) -> void:
	HeldPiece = piece
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and MouseIn:
		get_tree().get_first_node_in_group("GameHandler")._move_piece(global_position, HeldPiece)
		get_tree().get_first_node_in_group("GameHandler")._clear_overlays()
	


func _on_mouse_entered() -> void:
	MouseIn = true
	


func _on_mouse_exited() -> void:
	MouseIn = false
	

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Piece"):
		if area.get_parent().CurrentTeam == get_tree().get_first_node_in_group("GameHandler").player_team:
			hide()
			queue_free()
	
