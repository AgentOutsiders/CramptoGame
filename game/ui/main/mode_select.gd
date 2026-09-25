extends Control

@onready var finite_button: Button = $CenterContainer/HBoxContainer/FinitePanel/VBoxContainer/FiniteButton
@onready var infinite_button: Button = $CenterContainer/HBoxContainer/InfinitePanel/VBoxContainer/InfiniteButton

func _ready() -> void:
	finite_button.pressed.connect(_on_finite_pressed)
	infinite_button.pressed.connect(_on_infinite_pressed)

func _on_finite_pressed() -> void:
	GameManager.selected_mode = GameManager.GameMode.STORY
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")

func _on_infinite_pressed() -> void:
	GameManager.selected_mode = GameManager.GameMode.INFINITE
	get_tree().change_scene_to_file("res://scenes/menus/character_select.tscn")
