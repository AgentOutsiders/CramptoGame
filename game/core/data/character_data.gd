extends Resource
class_name CharacterData

@export var character_name: String = ""
@export var portrait: Texture2D
@export var idle_sheet: Texture2D
@export_multiline var description: String = ""

@export_group("Stats")
@export var scientific: int = 0
@export var literature: int = 0
@export_range(0.5, 2.0, 0.02) var methodology: float = 1.0
@export_range(0.5, 2.0, 0.02) var attendance: float = 1.0
@export var sleep: int = 0
@export var social_life: int = 0
@export var hobby: int = 0
