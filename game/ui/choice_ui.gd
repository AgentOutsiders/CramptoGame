extends PanelContainer
class_name ChoiceUI

#Noed customisé avec les info dans le choice donné dans le setup
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var cost_gain_label: Label = $MarginContainer/VBoxContainer/CostGainLabel
@onready var money_label: Label = $MarginContainer/VBoxContainer/MoneyLabel

#Sauvegarde du choice donné dans le setup pour le renvoyer plus tard
var _choice : Choice

#Declaration du signal clicked
signal clicked(choice: Choice)

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func setup(newChoice : Choice) -> void :
	if(!is_node_ready()):
		await ready;
	_choice = newChoice
	
	name_label.text = newChoice.get_choice_name()
	texture_rect.texture = newChoice.get_image()
	if newChoice.get_money_impact() < 0 :
		cost_gain_label.text = "Coût :"
	else :
		cost_gain_label.text = "Gain :"
	money_label.text = abs(newChoice.get_money_impact())
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(_choice)
