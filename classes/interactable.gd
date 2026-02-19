class_name Interactable
extends Control

@onready var game_handler: GameHandler = get_tree().get_first_node_in_group("GameHandler")
var MouseIn: bool = false

func _connect_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	


func _on_mouse_entered() -> void:
	MouseIn = true
	_change_sprite("res://art/normal/item_cover_2.png")
	_play_audio()
	

func _on_mouse_exited() -> void:
	MouseIn = false
	_change_sprite("res://art/normal/item_cover_1.png")
	

func _change_sprite(file_name: String) -> void:
	get_node("Cover").texture = load(file_name)
	

func _play_audio() -> void:
	var rank = randi_range(1, 3)
	get_node("AudioStreamPlayer").stream = load("res://audio/item_focus_" + str(rank) + ".mp3")
	get_node("AudioStreamPlayer").play()
	
