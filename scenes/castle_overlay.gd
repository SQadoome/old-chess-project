extends Node2D

@onready var game_handler: GameHandler = get_tree().get_first_node_in_group("GameHandler")

var TargetRook: Node2D
var MouseIn: bool = false
var Side: int = 0

func _set_rook(rook: Node2D) -> void:
	TargetRook = rook
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and MouseIn:
		var king = game_handler._get_king(TargetRook.CurrentTeam)
		if Side == 0:
			game_handler._castle(king, TargetRook, Vector2(-44, 0), Vector2(66, 0))
			get_tree().get_first_node_in_group("GameHandler")._clear_overlays()
		if Side == 1:
			game_handler._castle(king, TargetRook, Vector2(44, 0), Vector2(-44, 0))
			get_tree().get_first_node_in_group("GameHandler")._clear_overlays()
			
	


func _on_mouse_entered() -> void:
	MouseIn = true
	

func _on_mouse_exited() -> void:
	MouseIn = false
	
