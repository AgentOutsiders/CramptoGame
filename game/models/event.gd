extends Resource
class_name Event

@export var _title : String
@export var _description : String
@export var _image : Texture2D
@export var _choices : Array[Choice]

func get_title() -> String :
	return _title
	
func get_description() -> String :
	return _description
	
func get_image() -> Texture2D :
	return _image
	
func get_choices() -> Array[Choice] :
	_choices.make_read_only()
	return _choices
