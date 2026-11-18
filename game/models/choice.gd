extends Resource
class_name Choice

@export var _name : String
@export var _description : String
@export var _money_impact : int
@export var _required_item : Item
@export var _stats_modifiers : Array[StatModifier]
@export var _image : Texture2D

func get_choice_name() -> String :
	return _name;
	
func get_description() -> String :
	return _description;
	
func get_money_impact() -> int :
	return _money_impact;
	
func get_required_item() -> Item :
	return _required_item;
	
func get_stat_modifiers() -> Array[StatModifier] :
	_stats_modifiers.make_read_only();
	return _stats_modifiers;

func get_image() -> Texture2D :
	return _image

func get_stat_description() -> String :
	var retour : String = "Argent : " + str(_money_impact) + "€\n"
	for stat : StatModifier in _stats_modifiers:
		retour += stat.display_text() + "\n"
	return retour
		
