extends Control

@onready var scientific_label: Label = %ScientificLabel
@onready var scientific_bar: ProgressBar = %ScientificBar

@onready var literature_label: Label = %LiteratureLabel
@onready var literature_bar: ProgressBar = %LiteratureBar

@onready var methodology_label: Label = %MethodologyLabel
@onready var methodology_bar: ProgressBar = %MethodologyBar

@onready var attendance_label: Label = %AttendanceLabel
@onready var attendance_bar: ProgressBar = %AttendanceBar

@onready var sleep_label: Label = %SleepLabel
@onready var sleep_bar: ProgressBar = %SleepBar

@onready var social_life_label: Label = %SocialLifeLabel
@onready var social_life_bar: ProgressBar = %SocialLifeBar

@onready var leisure_label: Label = %LeisureLabel
@onready var leisure_bar: ProgressBar = %LeisureBar

@onready var character_preview: TextureRect = %CharacterPreview
@onready var character_name_label: Label = %CharacterNameLabel

@onready var thumbnail_row: HBoxContainer = %ThumbnailRow

var characters: Array[CharacterData] = []
var selected_character: CharacterData

func _ready() -> void:
	_load_characters()
	_populate_thumbnails()
	if characters.size() > 0:
		_select_character(characters[0])

func _load_characters() -> void:
	characters = [
		load("res://core/data/character1.tres"),
		load("res://core/data/character2.tres"),
		load("res://core/data/character3.tres"),
	]

func _populate_thumbnails() -> void:
	for character in characters:
		var button := Button.new()
		button.icon = character.portrait
		button.custom_minimum_size = Vector2(250, 250)
		button.expand_icon = true
		button.pressed.connect(_select_character.bind(character))
		thumbnail_row.add_child(button)

func _select_character(character: CharacterData) -> void:
	selected_character = character

	character_preview.texture = character.portrait
	character_name_label.text = character.character_name

	_setup_stat(scientific_label, scientific_bar, "Scientifique : ", 53, Color("ff4136"))
	_setup_stat(literature_label, literature_bar, "Littérature : ", 28, Color("ff851b"))
	_setup_stat(methodology_label, methodology_bar, "Méthodologie : ", 7, Color("0074d9"))
	_setup_stat(attendance_label, attendance_bar, "Assiduité : ", 40, Color("2ecc40"))
	_setup_stat(sleep_label, sleep_bar, "Sommeil : ", 70, Color("b10dc9"))
	_setup_stat(social_life_label, social_life_bar, "Vie sociale : ", 23, Color("ffdc00"))
	_setup_stat(leisure_label, leisure_bar, "Loisir : ", 91, Color("39cccc"))

func _setup_stat(label: Label, bar: ProgressBar, label_text: String, stat_value: int, color: Color) -> void:
	label.text = label_text
	label.custom_minimum_size.x = 220
	bar.max_value = 100
	bar.value = stat_value

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_left = 6
	fill_style.corner_radius_bottom_right = 6
	bar.add_theme_stylebox_override("fill", fill_style)

	bar.add_theme_color_override("font_color", Color.WHITE)
