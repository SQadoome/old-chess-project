extends Control


var Pool: Dictionary = {
	"Item1": {
		"Position": Vector2(),
		"Occupied": false
	},
	"Item2": {
		"Position": Vector2(),
		"Occupied": false
	}
}

var Team: int

func _ready() -> void:
	_animate_items()
	

func _set_team(team: int) -> void:
	Team = team
	

func _ask_to_add() -> bool:
	for i in Pool:
		if Pool[i]["Occupied"] == false:
			return true
	return false
	

func _clear_items() -> void:
	for i in Pool:
		if Pool[i]["Occupied"] == true:
			Pool[i]["Occupied"] = false
			get_node(i).get_child(1).queue_free()
	

func _remove_item(node_name: String) -> void:
	get_node(node_name).get_child(1).queue_free()
	Pool[node_name]["Occupied"] = false
	

func _add_item(type, path, team) -> void:
	for i in Pool:
		if Pool[i]["Occupied"] == false:
			var new_item = load(path).instantiate()
			get_node(i).add_child(new_item)
			new_item._set_type(type)
			new_item._set_team(team)
			new_item.position += Vector2(24, 10)
			Pool[i]["Occupied"] = true
			return
	

func _update_item(item: String) -> void:
	get_node(item).get_node("Sprite2D").texture = load(Pool[item]["Texture"])
	

func _animate_items() -> void:
	for i in get_children():
		var offset = randi_range(-1, -3)
		_tween_movement(i, offset)
	

func _tween_movement(item: Control, offset: int,) -> void:
	var new_tween = get_tree().create_tween()
	new_tween.tween_property(item, "global_position", Vector2(item.global_position.x, item.global_position.y+offset), 1.0)
	new_tween.finished.connect(_on_tween_finished.bind(new_tween, item, -offset))
	

func _on_tween_finished(move_tween: Tween, item, un_offset) -> void:
	move_tween.kill()
	_tween_movement(item, un_offset)
	
