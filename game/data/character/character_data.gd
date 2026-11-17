# Resource that holds all the data of one character
# Each character is a .tres file filled in the inspector
extends Resource
class_name CharacterData

# Name and description shown in the character select screen
@export var character_name: String = ""

# Small picture used in the character select thumbnails
@export var portrait: Texture2D

# Image with all the idle animation frames side by side
@export var idle_sheet: Texture2D
@export_multiline var description: String = ""

@export_group("Stats")

# Stats between 0 and 100
@export var scientific: int = 0
@export var literature: int = 0

# Multipliers between 0.5 and 2
@export_range(0.5, 2.0, 0.02) var methodology: float = 1.0
@export_range(0.5, 2.0, 0.02) var attendance: float = 1.0

# Stats between 0 and 100
@export var sleep: int = 0
@export var social_life: int = 0
@export var hobby: int = 0
