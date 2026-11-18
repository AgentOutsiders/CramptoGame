extends Resource
class_name Item

@export var _name : String = ""
@export var _price : float = 0.0
@export var _monthly_price : float = 0.0
@export var _texture : Texture2D
@export var _stat_modifiers : Array[StatModifier] = []
@export var _description : String = ""
@export var _max_owned : int = 0
# true if the item can be useful during some game events
@export var _can_be_used_in_events : bool = false

const EVENT_DESCRIPTION: String = "Cet item pourra vous être utile lors de certains évènements..."
# a sold item gives back 65% of its purchase price
const SELL_PRICE_RATIO: float = 0.65

func get_item_name() -> String:
	return _name

func get_price() -> float:
	return _price

# money given back when selling one copy
func get_sell_price() -> float:
	return _price * SELL_PRICE_RATIO

func get_monthly_price() -> float:
	return _monthly_price

func get_texture() -> Texture2D:
	return _texture

func get_stat_modifiers() -> Array[StatModifier]:
	return _stat_modifiers

func get_description() -> String:
	return _description

func get_max_owned() -> int:
	return _max_owned

func can_be_used_in_events() -> bool:
	return _can_be_used_in_events

# description shown to the player: the event one if the item can be used in events, otherwise none
func get_display_description() -> String:
	if _can_be_used_in_events:
		return EVENT_DESCRIPTION
	return ""
