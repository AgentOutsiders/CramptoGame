extends Control
class_name EventUI

#fenetre principale
@onready var title_label: Label = $TitleLabel
@onready var description_rich_text_label: RichTextLabel = $DescriptionPanelContainer/DescriptionVBoxContainer/DescriptionRichTextLabel
@onready var choice_container: HBoxContainer = $MarginContainer/ChoiceHBoxContainer
@onready var main_panel_container: PanelContainer = $MainPanelContainer


#fenetre avec toute les infos sur le choix (description, state et objet prérequis)
@onready var full_info_choice_label: Label = %FullInfoChoiceLabel
@onready var full_info_choice_texture_rect: TextureRect = %FullInfoChoiceTextureRect
@onready var full_info_description_rich_text_label: RichTextLabel = %FullInfoDescriptionRichTextLabel
@onready var full_info_stat_rich_text_label: RichTextLabel = %FullInfoStatRichTextLabel
@onready var full_info_item_texture_rect: TextureRect = %FullInfoItemTextureRect
@onready var full_info_item_name_label: Label = %FullInfoItemNameLabel
@onready var full_info_choice_color_rect: ColorRect = $FullInfoChoiceColorRect

#Variable modifiable depuis l'inspecteur
@export var no_image: Texture2D

#Constante qui contient la scène choice
const CHOICE_SCENE: PackedScene = preload("res://ui/choice.tscn")

func setup(event : Event) -> void :
	full_info_choice_color_rect.visible = false
	title_label.text = event.get_title()
	description_rich_text_label.text = event.get_description()
	main_panel_container.texture = event.get_image()
	for choice : Choice in event.get_choices():
		var choice_ui : ChoiceUI = CHOICE_SCENE.instantiate()
		choice_container.add_child(choice_ui)
		choice_ui.setup(choice)
		choice_ui.clicked.connect(full_info_choice_setup)
		
func full_info_choice_setup(choice : Choice) -> void :
	full_info_choice_label.text = choice.get_choice_name()
	full_info_choice_texture_rect.texture = choice.get_image()
	full_info_description_rich_text_label.text = choice.get_description()
	full_info_stat_rich_text_label.text = "A MODIFIER !!!" 		#j'ai pas encore la classe stat_modifier
	if(choice.get_required_item() != null) :
		full_info_item_name_label.text = "A MODIFIER !!!"			#Même problème mais avec la classe item
		# full_info_item_texture_rect.texture = 					Toujours le même problème
	else :
		full_info_item_name_label.text = "Aucun objet prérequis"	
		full_info_item_texture_rect.texture = no_image
		

func _on_cancel_button_pressed() -> void:
	full_info_choice_color_rect.visible = false


func _on_confir_button_pressed() -> void:
	pass # Ajouter la vadilation du choix puis passer à la suite du jeu
