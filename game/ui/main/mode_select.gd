extends Control

const MAIN_MENU_PATH: String = "res://ui/main/main_menu.tscn"
const CHARACTER_SELECT_PATH: String = "res://ui/character/character_select.tscn"

@onready var finite_button: Button = %FiniteButton
@onready var infinite_button: Button = %InfiniteButton
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton


func _ready() -> void:
	var group: ButtonGroup = ButtonGroup.new()
	finite_button.button_group = group
	infinite_button.button_group = group

	Highlighter.apply(self)

	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)
	confirm_button.mouse_entered.connect(confirm_button.grab_focus)
	confirm_button.mouse_exited.connect(confirm_button.release_focus)

	finite_button.pressed.connect(_on_finite_pressed)
	infinite_button.pressed.connect(_on_infinite_pressed)
	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	select_mode(GameManager.selected_mode)


func select_mode(mode: GameManager.GameMode) -> void:
	GameManager.selected_mode = mode
	if mode == GameManager.GameMode.STORY:
		finite_button.button_pressed = true
	else:
		infinite_button.button_pressed = true


func _on_finite_pressed() -> void:
	AudioManager.play_click()
	select_mode(GameManager.GameMode.STORY)


func _on_infinite_pressed() -> void:
	AudioManager.play_click()
	select_mode(GameManager.GameMode.INFINITE)


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_confirm_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(CHARACTER_SELECT_PATH)
