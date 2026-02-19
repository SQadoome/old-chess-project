class_name King
extends Piece

func _ready() -> void:
	CoinValue = 10
	Type = "king"
	Moves = {
	"Up": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(0, -22)
	},
	"Right": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, 0)
	},
	"Left": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, 0)
	},
	"Down": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(0, 22)
	},
	"UpRight": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, -22)
		},
	"UpLeft": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, -22)
		},
	"DownRight": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, 22)
	},
	"DownLeft": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, 22)
	},
	"Castle": {
		"Type": 10,
	}
}
	_set_team()
	

func _check() -> void:
	$Check.visible = true
	$AudioStreamPlayer.play()
	

func _un_check() -> void:
	$Check.visible = false
	

func _death() -> void:
	if CurrentTeam == 0:
		$Death.texture = load("res://art/normal/white_king_death.png")
	else:
		$Death.texture = load("res://art/normal/black_king_death.png")
	get_node("AnimationPlayer").play("death")
	

func _on_moved() -> void:
	Moves = {
	"Up": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(0, -22)
	},
	"Right": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, 0)
	},
	"Left": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, 0)
	},
	"Down": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(0, 22)
	},
	"UpRight": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, -22)
		},
	"UpLeft": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, -22)
		},
	"DownRight": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(22, 22)
	},
	"DownLeft": {
		"Type": 3,
		"Limit": 0,
		"Target": Vector2(-22, 22)
	}
	}
	
