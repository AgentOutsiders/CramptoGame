extends VBoxContainer
class_name OwnedItemSlot

@onready var _texture_rect: TextureRect = $ItemPanel/MarginContainer/TextureRect
@onready var _amount_label: Label = $Amount


func setup(item: Item) -> void:
	_texture_rect.texture = item._texture
	
func set_amount(amount : int) -> void:
	_amount_label.text = "x%d" % amount
	
	
	
