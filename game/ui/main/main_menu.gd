extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	for button in [play_button, settings_button, quit_button]:
		button.mouse_entered.connect(button.grab_focus)
	play_button.grab_focus()

func _on_play_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://ui/main/mode_select.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://ui/settings/settings.tscn")

func _on_quit_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.15).timeout  # laisse le clic se jouer avant de fermer
	get_tree().quit()
