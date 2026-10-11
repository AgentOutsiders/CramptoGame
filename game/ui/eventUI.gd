extends Control
class_name EventUI

#fenetre principale
@onready var title_label: Label = $TitleLabel
@onready var description_rich_text_label: RichTextLabel = $DescriptionPanelContainer/DescriptionVBoxContainer/DescriptionRichTextLabel
@onready var choice_container: HBoxContainer = $MarginContainer/ChoiceHBoxContainer

#fenetre avec toute les infos sur le choix (description, state et objet prérequis
@onready var full_info_choice_label: Label = %FullInfoChoiceLabel
@onready var full_info_choice_texture_rect: TextureRect = %FullInfoChoiceTextureRect
@onready var full_info_description_rich_text_label: RichTextLabel = %FullInfoDescriptionRichTextLabel
@onready var full_info_stat_rich_text_label: RichTextLabel = %FullInfoStatRichTextLabel
@onready var full_info_item_texture_rect: TextureRect = %FullInfoItemTextureRect
@onready var full_info_item_name_label: Label = %FullInfoItemNameLabel



const CHOICE_SCENE: PackedScene = preload("res://ui/choice.tscn")

func setup(event : Event) -> void :
	title_label.text = event.get_title()
	description_rich_text_label.text = event.get_description()
	for choice : Choice in event.get_choices():
		var choiceUI : ChoiceUI = CHOICE_SCENE.instantiate()
		choice_container.add_child(choiceUI)
		choiceUI.setup(choice)
		
func full_info_choice_setup(choice : Choice) -> void :
	full_info_choice_label.text = choice.get_choice_name()
	full_info_choice_texture_rect.texture = choice.get_image()
	full_info_description_rich_text_label.text = choice.get_description()
	full_info_stat_rich_text_label.text = "A MODIFIER !!!" 		#j'ai pas encore la classe stat_modifier
	full_info_item_name_label.text = "A MODIFIER !!!"			#Même problème mais avec la classe item
	# full_info_item_texture_rect.texture = 					Toujours le même problème
	
