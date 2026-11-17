# Main menu with the Play, Settings and Quit buttons
extends Control

# The three buttons of the menu
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


# Called when the scene is loaded
func _ready() -> void:
	# When a button is pressed, we call its function written below
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# When the mouse goes on a button, the button takes the focus so it gets highlighted
	play_button.mouse_entered.connect(play_button.grab_focus)
	settings_button.mouse_entered.connect(settings_button.grab_focus)
	quit_button.mouse_entered.connect(quit_button.grab_focus)

	# We put the chosen highlighter color on the menu
	Highlighter.apply(self)

	# The Play button is highlighted when the menu opens
	play_button.grab_focus()


# Goes to the mode select screen
func _on_play_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://ui/main/mode_select.tscn")


# Goes to the settings screen
func _on_settings_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://ui/settings/settings.tscn")


# Closes the game
func _on_quit_pressed() -> void:
	AudioManager.play_click()

	# We wait a little so the click sound can be heard before closing
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
