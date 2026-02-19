class_name Placeable
extends Node2D

@onready var game_handler: GameHandler = get_tree().get_first_node_in_group("GameHandler")

var item_type: String = ""
var team: int
var MouseIn: bool = false
var Selected: bool = false
var ORIGIN: Vector2
var CanPlace: bool = false

func _set_item(type: String, price) -> void:
	item_type = type
	get_node("Sprite2D").texture = load("res://art/normal/" + type + ".png")
	

func _process(delta: float) -> void:
	if Selected:
		global_position = get_global_mouse_position()
		if game_handler._ask_to_place(global_position): # this vector fixes the position with canvas layers stuff
			CanPlace = true
		else:
			CanPlace = false
	

func _set_team(new_team) -> void:
	team = new_team
	if team == 0:
		get_node("Sprite2D").texture = load("res://art/normal/white_" + item_type + ".png")
	else:
		get_node("Sprite2D").texture = load("res://art/normal/black_" + item_type + ".png")
	

func _select() -> void:
	if not Selected:
		ORIGIN = global_position
		Selected = true
	

func _place() -> void:
	pass
	

func _un_select() -> void:
	if Selected:
		Selected = false
		game_handler._ask_to_place(ORIGIN)
		global_position = ORIGIN
	
