class_name Pawn
extends Piece

func _ready() -> void:
	CoinValue = 2
	Type = "pawn"
	Moves = {
		"Up": {
			"Type": 2,
			"Limit": 2,
			"Direction": Vector2(0, -1),
			"CanCapture": false
		},
		"UpLeft": {
			"Type": 1,
			"Limit": 0,
			"Target": Vector2(-22, -22)
		},
		"UpRight": {
			"Type": 1,
			"Limit": 0,
			"Target": Vector2(22, -22)
		}
	}
	_set_team()


func _on_moved() -> void:
	Moves = {
		"Up": {
			"Type": 0,
			"Limit": 0,
			"Target": Vector2(0, -22)
		},
		"UpLeft": {
			"Type": 1,
			"Limit": 0,
			"Target": Vector2(-22, -22)
		},
		"UpRight": {
			"Type": 1,
			"Limit": 0,
			"Target": Vector2(22, -22)
		}
	}
	
