class_name Queen
extends Piece
func _ready() -> void:
	CoinValue = 12
	Type = "queen"
	Moves = {
	"Up": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(0, -1),
		"CanCapture": true
		},
	"Down": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(0, 1),
		"CanCapture": true
		},
	"Right": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(1, 0),
		"CanCapture": true
		},
	"Left": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(-1, 0),
		"CanCapture": true
		},
	"UpRight": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(1, -1),
		"CanCapture": true
		},
	"DownRight": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(1, 1),
		"CanCapture": true
		},
	"UpLeft": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(-1, -1),
		"CanCapture": true
		},
	"DownLeft": {
		"Type": 2,
		"Limit": 8,
		"Direction": Vector2(-1, 1),
		"CanCapture": true
		}
	}
	_set_team()
