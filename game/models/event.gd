extends Resource
class_name Event

@export var _title : String
@export var _description : String
@export var _choices : Array[Choice]

func get_title() -> String :
	return _title
	
func get_description() -> String :
	return _description
	
func get_choices() -> Array[Choice] :
	_choices.make_read_only()
	return _choices
