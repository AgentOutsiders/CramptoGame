extends Resource
class_name Choice

@export var _name : String
@export var _description : String
@export var _money_impact : int
@export var _required_item : Resource
@export var _stats_modifiers : Array[Resource]
@export var _image : Texture2D

func get_choice_name() -> String :
	return _name;
	
func get_description() -> String :
	return _description;
	
func get_money_impact() -> int :
	return _money_impact;
	
func get_required_item() -> Resource :
	return _required_item;
	
func get_stat_modifiers() -> Array[Resource] :
	_stats_modifiers.make_read_only();
	return _stats_modifiers;

func get_image() -> Texture2D :
	return _image
