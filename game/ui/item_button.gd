extends Button
class_name ItemButton

# signal declaration that carries an item
signal item_selected(item : Item)

var _item : Item

@onready var _icon_texture_rect: TextureRect = $ContentVBox/IconTextureRect
@onready var _name_price_label: Label = $ContentVBox/NamePriceLabel

# public function so no _ (used by the shop)
func setup(item : Item) -> void:
	_item = item
	# works like a printf, e.g. (laptop - 100 $)
	# .0f = float with 0 digits after the decimal point
	_name_price_label.text = "%s - %.0f $" % [item.get_item_name(), item.get_price()]
	_icon_texture_rect.texture = item.get_texture()
	

# private function of the Button class, overridden here
func _pressed() -> void:
	# .emit = fires the signal declared above
	item_selected.emit(_item)
