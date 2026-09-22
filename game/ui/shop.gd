extends Control
class_name Shop

@export var _available_items: Array[Item] = []


@onready var _item_container: HBoxContainer = $ItemContainer
@onready var _confirmation_popup: PopupPanel = $PurchaseConfirmationPopup

# PackedScene = le type Godot qui représente "un fichier .tscn chargé en mémoire, prêt à être dupliqué (instancié)"
# preaload pour charger la scène directement à la compilation et pas à l'éxecution
const ITEM_BUTTON_SCENE: PackedScene = preload("res://ui/item_button.tscn")

func _ready() -> void:
	for item in _available_items:
		var button: ItemButton = ITEM_BUTTON_SCENE.instantiate()
		_item_container.add_child(button)
		# appel de setup() dans item_button.gd qui remplie le bouton d'un item et d'un text
		button.setup(item)
		# quand le signal du bouton est déclanché = connexion à on_item_selected()
		button.item_selected.connect(_on_item_selected)
		
	_confirmation_popup.purchase_confirmed.connect(_on_purchase_confirmed)

func _on_item_selected(item: Item) -> void:
	_confirmation_popup.show_item(item)
	print("Item sélectionné dans la boutique : ", item._name)
	
func _on_purchase_confirmed(item: Item) -> void:
	print("Achat confirmé dans la boutique : ", item._name)

	
