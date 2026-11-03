extends Resource
class_name Item

@export var _name : String = ""
@export var _price : float = 0.0
@export var _monthly_price : float = 0.0
@export var _texture : Texture2D
@export var _stat_modifiers : Array[StatModifier] = []
@export var _description : String = ""
@export var _max_owned : int = 0
# true si l'item pourra servir lors de certains évènements du jeu
@export var _can_be_used_in_events : bool = false

const EVENT_DESCRIPTION: String = "Cet item pourra vous être utile lors de certains évènements..."

# pas get_name() : ce nom existe déjà dans Resource (getter de resource_name)
func get_item_name() -> String:
	return _name

func get_price() -> float:
	return _price

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

# booléen : nommé comme une question, comme la variable (can_)
func can_be_used_in_events() -> bool:
	return _can_be_used_in_events

# description affichée au joueur : celle des évènements si l'item peut y servir, sinon aucune
func get_display_description() -> String:
	if _can_be_used_in_events:
		return EVENT_DESCRIPTION
	return ""
