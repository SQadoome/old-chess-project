extends Piece

func _ready() -> void:
	CoinValue = 5
	Type = "knight"
	Moves = {
	"UpRight2": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(44, -22)
	},
	"Up2Right": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, -44)
	},
	"UpLeft2": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-44, -22)
	},
	"Up2Left": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, -44)
	},
	"DownRight2": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(44, 22)
	},
	"Down2Right": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, 44)
	},
	"DownLeft2": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-44, 22)
	},
	"Down2Left": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, 44)
		}
	}
	_set_team()
	

	
