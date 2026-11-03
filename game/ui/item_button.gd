extends Button
class_name ItemButton

# déclaration d'un signal qui transporte un item
signal item_selected(item : Item)

var _item : Item

@onready var _icon_texture_rect: TextureRect = $ContentVBox/IconTextureRect
@onready var _name_price_label: Label = $ContentVBox/NamePriceLabel

# fonction publique donc pas de _ (utilisée dans le shop)
func setup(item : Item) -> void:
	_item = item
	# le fonctionnement ressemble à un printf ex:(ordi - 100 $)
	#.0f = flottant avec 0 chiffres après la virgule
	_name_price_label.text = "%s - %.0f $" % [item.get_item_name(), item.get_price()]
	_icon_texture_rect.texture = item.get_texture()
	

# fonction privée propre à la classe Button, refdéfinie ici
func _pressed() -> void:
	# .emit = déclanchement du signal déclaré plus haut
	item_selected.emit(_item)
