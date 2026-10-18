extends Control

const MAIN_MENU_PATH := "res://ui/main/main_menu.tscn"
const CHARACTER_SELECT_PATH := "res://ui/character/character_select.tscn"
const SELECTED_BORDER_COLOR := Color("ffdc00")

@onready var finite_button: Button = %FiniteButton
@onready var infinite_button: Button = %InfiniteButton
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton

func _ready() -> void:
	var group := ButtonGroup.new()
	for button in [finite_button, infinite_button]:
		button.toggle_mode = true
		button.button_group = group
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		# Le bouton du mode choisi garde son style normal, entouré d'un cadre jaune
		var selected_style: StyleBox = button.get_theme_stylebox("normal").duplicate()
		if selected_style is StyleBoxFlat:
			selected_style.border_color = SELECTED_BORDER_COLOR
			selected_style.set_border_width_all(5)
		button.add_theme_stylebox_override("pressed", selected_style)
		button.add_theme_stylebox_override("hover_pressed", selected_style)

	finite_button.pressed.connect(_on_mode_pressed.bind(GameManager.GameMode.STORY))
	infinite_button.pressed.connect(_on_mode_pressed.bind(GameManager.GameMode.INFINITE))
	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	_select_mode(GameManager.selected_mode)


func _on_mode_pressed(mode: GameManager.GameMode) -> void:
	AudioManager.play_click()
	_select_mode(mode)


func _select_mode(mode: GameManager.GameMode) -> void:
	GameManager.selected_mode = mode
	var is_story := mode == GameManager.GameMode.STORY
	(finite_button if is_story else infinite_button).button_pressed = true


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_confirm_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(CHARACTER_SELECT_PATH)
