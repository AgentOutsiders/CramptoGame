extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	play_button.mouse_entered.connect(play_button.grab_focus)
	settings_button.mouse_entered.connect(settings_button.grab_focus)
	quit_button.mouse_entered.connect(quit_button.grab_focus)

	Highlighter.apply(self)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://ui/main/mode_select.tscn")


func _on_settings_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://ui/settings/settings.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
