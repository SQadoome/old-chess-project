extends Control

@onready var game_handler: GameHandler = get_tree().get_first_node_in_group("GameHandler")

var item_pool: Array = []
var refresh_cost: int = 3
var ORIGIN: int = 416

func _refresh() -> void:
	if game_handler._ask_to_refresh(refresh_cost):
		game_handler._refresh.rpc(refresh_cost, game_handler.player_team)
		get_node("Refresh/AudioStreamPlayer").play()
		randomize()
		refresh_cost = refresh_cost*1.5 + randi_range(0, 3)
		$Refresh/Label.text = str(refresh_cost)
		
		for i in $ItemPool.get_children():
			i._randomize_item()
			i._randomize_offset()
		


func _reset_shop() -> void:
	for i in $ItemPool.get_children():
			i._randomize_item()
			i._randomize_offset()
	refresh_cost = 3
	$Refresh/Label.text = str(refresh_cost)
	

var moving = false
func _on_mouse_entered() -> void:
	_enter_board()
	


func _on_mouse_exited() -> void:
	_leave_board()
	

func _enter_board() -> void:
	moving = true
	_move(Vector2(ORIGIN - 96, global_position.y))
	

func _leave_board() -> void:
	moving = true
	_move(Vector2(ORIGIN, global_position.y))
	

func _move(target: Vector2) -> void:
	var new_tween = get_tree().create_tween()
	new_tween.tween_property(self, "position", target, 0.5)
	new_tween.finished.connect(_on_move_finished.bind(new_tween))
	

func _on_move_finished(move_tween: Tween) -> void:
	move_tween.kill()
	moving = false
	
