extends Control
class_name EventUI

@onready var title_label: Label = $TitleLabel
@onready var description_rich_text_label: RichTextLabel = $DescriptionPanelContainer/DescriptionVBoxContainer/DescriptionRichTextLabel
@onready var choice_container: HBoxContainer = $MarginContainer/ChoiceHBoxContainer

const CHOICE_SCENE: PackedScene = preload("res://ui/choice.tscn")

func setup(event : Event) -> void :
	title_label.text = event.get_title()
	description_rich_text_label.text = event.get_description()
	for choice : Choice in event.get_choices():
		var choiceUI : ChoiceUI = CHOICE_SCENE.instantiate()
		choice_container.add_child(choiceUI)
		choiceUI.setup(choice)
	
