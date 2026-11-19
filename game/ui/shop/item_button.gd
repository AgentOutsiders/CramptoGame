extends Button
class_name ItemButton

# signal declaration that carries an item
signal item_selected(item : Item)

var _item : Item

@onready var _icon_texture_rect: TextureRect = $ContentVBox/IconTextureRect
@onready var _name_label: Label = $ContentVBox/TextVBox/NameLabel
@onready var _price_label: Label = $ContentVBox/TextVBox/PriceLabel

# public function so no _ (used by the shop)
func setup(item : Item) -> void:
	_item = item
	# The name on the first line and the price on the line below
	_name_label.text = item.get_item_name()
	# works like a printf, e.g. 100 $
	# .0f = float with 0 digits after the decimal point
	_price_label.text = "%.0f $" % item.get_price()
	_icon_texture_rect.texture = item.get_texture()
	

# private function of the Button class, overridden here
func _pressed() -> void:
	# .emit = fires the signal declared above
	item_selected.emit(_item)
