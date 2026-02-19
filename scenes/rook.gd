extends Piece

var CanCastle = true

func _ready() -> void:
	CoinValue = 8
	Type = "rook"
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
		}
	}
	_set_team()


func _on_moved() -> void:
	CanCastle = false
	
