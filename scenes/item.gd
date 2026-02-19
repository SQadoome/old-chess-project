extends Interactable

var ORIGIN: Vector2
var Cost: int
var Pool: Array = [
	"pawn", "knight", "bishop", "rook", "queen", "bomb"
]

var Item: String
var Type: String

func _ready() -> void:
	ORIGIN = position
	_randomize_offset()
	_connect_signals()
	_randomize_item()
	


func _randomize_item() -> void:
	$Cover.show()
	$Sprite2D.show()
	$Buy.show()
	$Label.show()
	
	Type = Pool[randi_range(0, Pool.size() - 1)]
	Cost = DATA.SHOP_PRICES[Type]
	randomize()
	Item = "res://scenes/placeable_piece.tscn"
	
	if Type == "bomb":
		Item = "res://scenes/placeable_bomb.tscn"
	
	get_node("Sprite2D").hframes = 3
	get_node("Sprite2D").frame = 0
	if game_handler.player_team == 0:
		get_node("Sprite2D").texture = load("res://art/normal/" + "white_" + Type + ".png")
	else:
		get_node("Sprite2D").texture = load("res://art/normal/" + "black_" + Type + ".png")
	$Label.text = str(Cost)
	

func _randomize_offset() -> void:
	randomize()
	await get_tree().create_timer(randf_range(0, 0.5)).timeout
	position = ORIGIN + Vector2(randi_range(-1, 1), randi_range(-2, 2))
	

func _on_buy_pressed() -> void:
	if game_handler._ask_to_buy(Cost):
		$Buy/AudioStreamPlayer.play()
		game_handler._update_inventory.rpc(Type, Item, game_handler.player_team, Cost)
		$Cover.hide()
		$Sprite2D.hide()
		$Buy.hide()
		$Label.hide()
	
