extends PanelContainer
class_name ChoiceUI

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var cost_gain_label: Label = $MarginContainer/VBoxContainer/CostGainLabel
@onready var money_label: Label = $MarginContainer/VBoxContainer/MoneyLabel



func setup(choice : Choice) -> void :
	if(!is_node_ready()):
		await ready;
	
	name_label.text = choice.get_choice_name()
	texture_rect.texture = choice.get_image()
	if choice.get_money_impact() < 0 :
		cost_gain_label.text = "Coût :"
	else :
		cost_gain_label.text = "Gain :"
	money_label.text = abs(choice.get_money_impact())
	
