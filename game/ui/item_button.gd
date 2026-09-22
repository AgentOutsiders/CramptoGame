extends Button
class_name ItemButton

# déclaration d'un signal qui transporte un item
signal item_selected(item : Item)

var _item : Item

@onready var item_icon: TextureRect = $VBoxContainer/ItemIcon
@onready var item_label: Label = $VBoxContainer/ItemLabel

# fonction publique donc pas de _ (utilisée dans le shop)
func setup(item : Item) -> void:
	_item = item
	# le fonctionnement ressemble à un printf ex:(ordi - 100 $)
	#.0f = flottant avec 0 chiffres après la virgule
	item_label.text = "%s - %.0f $" % [item._name, item._price]
	item_icon.texture = item._texture
	

# fonction privée propre à la classe Button, refdéfinie ici
func _pressed() -> void:
	# .emit = déclanchement du signal déclaré plus haut
	item_selected.emit(_item)
