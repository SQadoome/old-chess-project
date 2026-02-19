extends Node2D

var collected: bool = false
var winner_team: int

func _ready() -> void:
	$AnimationPlayer.play("win")
	await get_tree().create_timer(0.5).timeout
	$Area2D.monitorable = true
	

func _set_image(team: int) -> void:
	if team == 0:
		$Structure/Sprite2D.texture = load("res://art/normal/white_trophy.png")
		$Structure/Shiny.texture = load("res://art/normal/white_shiny.png")
	else:
		$Structure/Sprite2D.texture = load("res://art/normal/black_trophy.png")
		$Structure/Shiny.texture = load("res://art/normal/black_shiny.png")
	winner_team = team
	


func _on_mouse_entered() -> void:
	if not collected and winner_team == get_tree().get_first_node_in_group("GameHandler").player_team:
		_end.rpc()
	

@rpc("any_peer", "call_local", "reliable")
func _end() -> void:
	$EndGame.play()
	collected = true
	$AnimationPlayer.play("claim")
	var new_tween = get_tree().create_tween()
	new_tween.tween_property(self, "position", Vector2.ZERO, 3.0)
	

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "claim":
		get_tree().get_first_node_in_group("GameHandler")._show_rematch()
	
