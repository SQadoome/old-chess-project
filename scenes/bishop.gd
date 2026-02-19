class_name Bishop
extends Piece

func _ready() -> void:
	CoinValue = 5
	Type = "bishop"
	Moves = {
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
