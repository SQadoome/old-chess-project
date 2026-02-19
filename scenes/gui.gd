extends Control

func _update_coins(target: String, new_value: int) -> void:
	get_node("P" + target + "Coins").text = ("        " + str(new_value))
	
