# Screen where the player chooses the game mode: story or infinite
extends Control

# Paths of the previous and next screens
const MAIN_MENU_PATH: String = "res://ui/main/main_menu.tscn"
const CHARACTER_SELECT_PATH: String = "res://ui/character/character_select.tscn"

# The two mode buttons, then the back and confirm buttons
@onready var finite_button: Button = %FiniteButton
@onready var infinite_button: Button = %InfiniteButton
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton


# Called when the scene is loaded
func _ready() -> void:
	# We put the two mode buttons in a group so only one can be pressed at a time
	var group: ButtonGroup = ButtonGroup.new()
	finite_button.button_group = group
	infinite_button.button_group = group

	# We put the chosen highlighter color on the screen
	Highlighter.apply(self)

	# When the mouse goes on a button it gets highlighted, and when it leaves it is not anymore
	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)
	confirm_button.mouse_entered.connect(confirm_button.grab_focus)
	confirm_button.mouse_exited.connect(confirm_button.release_focus)

	# When a button is pressed, we call its function written below
	finite_button.pressed.connect(_on_finite_pressed)
	infinite_button.pressed.connect(_on_infinite_pressed)
	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	# We show the mode that was already chosen before
	select_mode(GameManager.selected_mode)


# Saves the chosen mode in GameManager and presses the right button
func select_mode(mode: GameManager.GameMode) -> void:
	GameManager.selected_mode = mode

	# We press the button of this mode and the group releases the other one
	if mode == GameManager.GameMode.STORY:
		finite_button.button_pressed = true
	else:
		infinite_button.button_pressed = true


# Chooses the story mode
func _on_finite_pressed() -> void:
	AudioManager.play_click()
	select_mode(GameManager.GameMode.STORY)


# Chooses the infinite mode
func _on_infinite_pressed() -> void:
	AudioManager.play_click()
	select_mode(GameManager.GameMode.INFINITE)


# Goes back to the main menu
func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


# Goes to the character select screen
func _on_confirm_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(CHARACTER_SELECT_PATH)
