extends Control
class_name Shop

@export var _available_items: Array[Item] = []
@export var _current_money: int = 100000
# Item -> quantité (int)
var _owned_items: Dictionary = {}
# Item -> OwnedItemSlot   
var _owned_panels: Dictionary = {} 
const MAX_OWNED_PER_ITEM: int = 10 

@onready var _item_container: GridContainer = $MarginContainer4/ScrollContainer/ItemContainer
@onready var _confirmation_popup: PopupPanel = $PurchaseConfirmationPopup
@onready var _notification_timer: Timer = $NotificationTimer
@onready var _notification_label: Label = $MarginContainer/Notificationlabel
@onready var _money_label: Label = $MarginContainer2/MoneyLabel
@onready var _owned_items_grid: GridContainer = $MarginContainer5/ScrollContainer2/OwnedItemsGrid


# PackedScene = le type Godot qui représente "un fichier .tscn chargé en mémoire, prêt à être dupliqué (instancié)"
# preaload pour charger la scène directement à la compilation et pas à l'éxecution
const ITEM_BUTTON_SCENE: PackedScene = preload("res://ui/item_button.tscn")
const OWNED_ITEM_SLOT_SCENE: PackedScene = preload("res://ui/owned_item_slot.tscn")

func _ready() -> void:
	_money_label.text = str(_current_money) + "$"
	for item in _available_items:
		var button: ItemButton = ITEM_BUTTON_SCENE.instantiate()
		_item_container.add_child(button)
		# appel de setup() dans item_button.gd qui remplie le bouton d'un item et d'un text
		button.setup(item)
		# quand le signal du bouton est déclanché = connexion à on_item_selected()
		button.item_selected.connect(_on_item_selected)
		
		
	_confirmation_popup.purchase_confirmed.connect(_on_purchase_confirmed)
	_notification_timer.timeout.connect(_on_notification_timeout)
	
func _on_item_selected(item: Item) -> void:
	_confirmation_popup.show_item(item)
	print("Item sélectionné dans la boutique : ", item._name)
	
func _on_purchase_confirmed(item: Item, quantity: int) -> void:
	if quantity == 0:
		return
	#On regarde d'abord si on peut faire l'achat
	var total_price: int = quantity * int(item._price)
	if total_price > _current_money:
		_notification_label.add_theme_color_override("font_color", Color(0.962, 0.0, 0.0, 1.0))
		_show_notification("Pas assez d'argent !")
		return
	
	#Si oui, on regarde ce qui sera réélement débité on fonction de la limite obtenable de l'item
	var added_quantity: int = _add_owned_item(item, quantity)
	if added_quantity == 0:
		return

	_current_money -= added_quantity * int(item._price)
	_money_label.text = str(_current_money) + "$"
	_notification_label.add_theme_color_override("font_color", Color(0.01, 0.82, 0.0, 1.0))
	
	if added_quantity < quantity:
		_show_notification("Seulement %d ajouté(s) (limite atteinte)" % added_quantity)
	else:
		_show_notification("Achat effectué !")
	
func _add_owned_item(item: Item, quantity: int) -> int:
	var current_amount: int = _owned_items.get(item, 0)
	var quantity_to_add: int = min(quantity, item._max_owned - current_amount)

	if quantity_to_add <= 0:
		_notification_label.add_theme_color_override("font_color", Color(0.962, 0.0, 0.0, 1.0))
		_show_notification("Impossible d'en avoir plus !")
		return 0

	if not _owned_items.has(item):
		var panel: OwnedItemSlot = OWNED_ITEM_SLOT_SCENE.instantiate()
		_owned_items_grid.add_child(panel)
		panel.setup(item)
		_owned_panels[item] = panel

	_owned_items[item] = current_amount + quantity_to_add
	_owned_panels[item].set_amount(_owned_items[item])
	return quantity_to_add
	

func _show_notification(message : String) -> void:
	_notification_label.text = message
	_notification_label.visible = true
	_notification_timer.start(5)
	
func _on_notification_timeout() -> void:
	_notification_label.visible = false
