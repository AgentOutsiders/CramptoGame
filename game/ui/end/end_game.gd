extends Control

const MAIN_MENU_PATH: String = "res://ui/main/main_menu.tscn"

@onready var title_label: Label = %TitleLabel
@onready var reason_label: Label = %ReasonLabel
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	if GameManager.has_won:
		title_label.text = "Victoire"
	else:
		title_label.text = "Défaite"

	match GameManager.end_reason:
		GameManager.DEFEAT_RENT:
			reason_label.text = "Raison : loyer impayé"
		GameManager.DEFEAT_DEPRESSION:
			reason_label.text = "Raison : dépression"
		GameManager.DEFEAT_SCHOOL:
			reason_label.text = "Raison : échec scolaire"
		_:
			reason_label.text = ""


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
