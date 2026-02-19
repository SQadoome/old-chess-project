extends Node2D

signal mouse_entered
signal mouse_exited

@export var SIZE: Vector2
var mouse_position: Vector2
var screen_size: Vector2
var MOUSEIN: Vector2 = Vector2.ZERO
var already_detected: bool = false

func _process(delta: float) -> void:
	screen_size = get_viewport().size
	mouse_position = get_global_mouse_position()
	if mouse_position.x > (global_position.x - SIZE.x/2.0) and mouse_position.x < (global_position.x + SIZE.x/2.0):
		MOUSEIN.x = 1
	else:
		MOUSEIN.x = 0
	if mouse_position.y > (global_position.y - SIZE.y/2.0) and mouse_position.y < (global_position.y + SIZE.y/2.0):
		MOUSEIN.y = 1
	else:
		MOUSEIN.y = 0
	if MOUSEIN == Vector2(1, 1) and not already_detected:
		emit_signal("mouse_entered")
		already_detected = true
	if already_detected and MOUSEIN != Vector2(1, 1):
		already_detected = false
		emit_signal("mouse_exited")
	
