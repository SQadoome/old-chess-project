extends Node2D


func _ready() -> void:
	global_position += Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
	

func _follow_target(target: Vector2) -> void:
	await get_tree().create_timer(0.4).timeout
	var new_tween = get_tree().create_tween()
	randomize()
	var life_time = randf_range(0.3, 0.5)
	new_tween.tween_property(self, "global_position", target, life_time)
	new_tween.finished.connect(_on_finished.bind(new_tween))
	

func _on_finished(tween: Tween) -> void:
	tween.kill()
	call_deferred("queue_free")
	
