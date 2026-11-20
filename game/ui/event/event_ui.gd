extends Control
class_name EventUI

#fenetre principale
@onready var title_label: Label = %TitleLabel
@onready var description_rich_text_label: RichTextLabel = %DescriptionRichTextLabel
@onready var choice_container: HBoxContainer = %ChoiceHBoxContainer
@onready var background_texture_rect: TextureRect = %BackgroundTextureRect		#Pas utilisé pour l'instant il faut ajouter le changement de saison (pour faire jolie tout beau) 


#fenetre avec toute les infos sur le choix (description, state et objet prérequis)
@onready var full_info_choice_label: Label = %FullInfoChoiceLabel
@onready var full_info_choice_texture_rect: TextureRect = %FullInfoChoiceTextureRect
@onready var full_info_description_rich_text_label: RichTextLabel = %FullInfoDescriptionRichTextLabel
@onready var full_info_stat_rich_text_label: RichTextLabel = %FullInfoStatRichTextLabel
@onready var full_info_item_texture_rect: TextureRect = %FullInfoItemTextureRect
@onready var full_info_item_name_label: Label = %FullInfoItemNameLabel
@onready var full_info_choice_color_rect: ColorRect = %FullInfoChoiceColorRect

#Variable modifiable depuis l'inspecteur
@export var no_image: Texture2D		#c'est pour quand le choix n'a pas d'objet prérequis 

var selected_choice: Choice = null

#Constante qui contient la scène choice
const CHOICE_SCENE: PackedScene = preload("res://ui/event/choice.tscn")


#Fonction a lancer au démarrage avec en paramètre une resource Event pour initialisé tout les éléments 
func setup(event : Event) -> void :
	full_info_choice_color_rect.visible = false
	title_label.text = event.get_title()
	description_rich_text_label.text = event.get_description()
	for choice : Choice in event.get_choices():
		var choice_ui : ChoiceUI = CHOICE_SCENE.instantiate()
		choice_container.add_child(choice_ui)
		choice_ui.setup(choice)
		choice_ui.clicked.connect(full_info_choice_setup)

#Fonction connecté au signal clicked des choices qui permet de faire apparaitre la fenêtre full info choice avec les bonnes info évidement
func full_info_choice_setup(choice : Choice) -> void :
	selected_choice = choice
	full_info_choice_label.text = choice.get_choice_name()
	full_info_choice_texture_rect.texture = choice.get_image()
	full_info_description_rich_text_label.text = choice.get_description()
	full_info_stat_rich_text_label.text = choice.get_stat_description()
	if(choice.get_required_item() != null) :
		full_info_item_name_label.text = choice.get_required_item().get_item_name()	
		full_info_item_texture_rect.texture = choice.get_required_item().get_texture()
	else :
		full_info_item_name_label.text = "Aucun objet prérequis"	
		full_info_item_texture_rect.texture = no_image
	full_info_choice_color_rect.visible = true
		

func _on_cancel_button_pressed() -> void:
	full_info_choice_color_rect.visible = false


func _on_confir_button_pressed() -> void:
	if selected_choice == null:
		return

	var required_item: Item = selected_choice.get_required_item()
	if required_item != null and int(GameManager.inventory.get(required_item, 0)) <= 0:
		full_info_description_rich_text_label.text = "Objet requis manquant : " + required_item.get_item_name()
		return

	GameManager.apply_money_change(selected_choice.get_money_impact())
	for modifier: StatModifier in selected_choice.get_stat_modifiers():
		GameManager.apply_stat_modifier(modifier)

	if not GameManager.is_game_over:
		GameManager.advance_after_event()

#test temporaire à retirer pour la version final
func _ready() -> void:
	if not GameManager.is_game_over:
		var event_resources: Array[Event] = []
		var event_directory: DirAccess = DirAccess.open("res://data/event")
		if event_directory != null:
			event_directory.list_dir_begin()
			var file_name: String = event_directory.get_next()
			while file_name != "":
				if not event_directory.current_is_dir() and file_name.ends_with(".tres"):
					var event_resource: Resource = load("res://data/event/" + file_name)
					if event_resource is Event:
						event_resources.append(event_resource)
				file_name = event_directory.get_next()
			event_directory.list_dir_end()

		if event_resources.size() > 0:
			event_resources.shuffle()
			setup(event_resources[0])
