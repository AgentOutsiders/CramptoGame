extends Control

const MODE_SELECT_PATH := "res://ui/main/mode_select.tscn"
const FONT := preload("res://assets/font/PixelOperator8.ttf")

const STAT_MAX := 100
const BAR_ANIMATION_TIME := 0.25
const PREVIEW_FADE_TIME := 0.15

# Une ligne par statistique : propriété de CharacterData, libellé affiché, couleur de la barre
const STATS := [
	{"property": "scientific", "label": "Scientifique", "color": Color("ff4136")},
	{"property": "literature", "label": "Littérature", "color": Color("ff851b")},
	{"property": "methodology", "label": "Méthodologie", "color": Color("0074d9")},
	{"property": "attendance", "label": "Assiduité", "color": Color("2ecc40")},
	{"property": "sleep", "label": "Sommeil", "color": Color("b10dc9")},
	{"property": "social_life", "label": "Vie sociale", "color": Color("ffdc00")},
	{"property": "leisure", "label": "Loisir", "color": Color("39cccc")},
]

const THUMBNAIL_SIZE := Vector2(150, 150)
const PANEL_COLOR := Color(0.13, 0.15, 0.18, 0.92)
const BORDER_COLOR := Color(0.42, 0.44, 0.49)
const HOVER_BORDER_COLOR := Color(0.85, 0.87, 0.92)
const SELECTED_BORDER_COLOR := Color("ffdc00")

@onready var character_preview: TextureRect = %CharacterPreview
@onready var character_name_label: Label = %CharacterNameLabel
@onready var stats_grid: GridContainer = %StatsGrid
@onready var thumbnail_row: HBoxContainer = %ThumbnailRow
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton

var characters: Array[CharacterData] = []
var selected_character: CharacterData

var _stat_bars: Dictionary = {}
var _stat_value_labels: Dictionary = {}
var _thumbnails: Array[Button] = []
var _bars_tween: Tween
var _preview_tween: Tween


func _ready() -> void:
	_load_characters()
	_build_stat_rows()
	_populate_thumbnails()

	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	if characters.size() > 0:
		_select_character(0)


func _load_characters() -> void:
	characters = [
		load("res://core/data/character1.tres"),
		load("res://core/data/character2.tres"),
		load("res://core/data/character3.tres"),
	]


func _build_stat_rows() -> void:
	for stat in STATS:
		var name_label := _create_label(stat.label, 30)
		stats_grid.add_child(name_label)

		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(420, 28)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.max_value = STAT_MAX
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", _create_box(Color(0.08, 0.09, 0.11), BORDER_COLOR, 2))
		bar.add_theme_stylebox_override("fill", _create_box(stat.color, stat.color, 0))
		stats_grid.add_child(bar)

		var value_label := _create_label("0", 30)
		value_label.custom_minimum_size.x = 80
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_grid.add_child(value_label)

		_stat_bars[stat.property] = bar
		_stat_value_labels[stat.property] = value_label


func _populate_thumbnails() -> void:
	var group := ButtonGroup.new()
	for i in characters.size():
		var character := characters[i]
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = group
		button.icon = character.portrait
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.custom_minimum_size = THUMBNAIL_SIZE
		button.tooltip_text = character.character_name
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_stylebox_override("normal", _create_box(PANEL_COLOR, BORDER_COLOR, 3, 12))
		button.add_theme_stylebox_override("hover", _create_box(PANEL_COLOR, HOVER_BORDER_COLOR, 3, 12))
		button.add_theme_stylebox_override("pressed", _create_box(PANEL_COLOR, SELECTED_BORDER_COLOR, 5, 12))
		button.add_theme_stylebox_override("hover_pressed", _create_box(PANEL_COLOR, SELECTED_BORDER_COLOR, 5, 12))
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.pressed.connect(_on_thumbnail_pressed.bind(i))
		thumbnail_row.add_child(button)
		_thumbnails.append(button)


func _on_thumbnail_pressed(index: int) -> void:
	AudioManager.play_click()
	_select_character(index)


func _select_character(index: int) -> void:
	var character := characters[index]
	if character == selected_character:
		return
	selected_character = character
	_thumbnails[index].button_pressed = true

	character_preview.texture = character.portrait
	character_name_label.text = character.character_name
	_animate_preview()

	if _bars_tween:
		_bars_tween.kill()
	_bars_tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	for stat in STATS:
		var value: int = character.get(stat.property)
		_stat_value_labels[stat.property].text = str(value)
		_bars_tween.tween_property(_stat_bars[stat.property], "value", value, BAR_ANIMATION_TIME)


func _animate_preview() -> void:
	if _preview_tween:
		_preview_tween.kill()
	character_preview.modulate.a = 0.0
	_preview_tween = create_tween()
	_preview_tween.tween_property(character_preview, "modulate:a", 1.0, PREVIEW_FADE_TIME)


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MODE_SELECT_PATH)


func _on_confirm_pressed() -> void:
	AudioManager.play_click()
	GameManager.selected_character = selected_character
	# TODO : lancer la partie quand la scène de jeu existera


func _create_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	return label


func _create_box(bg_color: Color, border_color: Color, border_width: int, padding: float = 0.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg_color
	box.border_color = border_color
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(4)
	box.set_content_margin_all(padding)
	return box
