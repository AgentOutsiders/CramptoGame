extends Control
class_name Shop

# Signaux pour relier le shop avec l'instance du joueur,
# émis après un achat ou une vente réussi(e)
# quantity = nombre d'exemplaires réellement achetés ou vendus
signal item_purchased(item: Item, quantity: int)
signal item_sold(item: Item, quantity: int)

@export var _available_items: Array[Item] = []
@export var _current_money: int = 100000
# Item -> quantité (int)
var _owned_items: Dictionary = {}
# Item -> OwnedItemSlot   
var _owned_panels: Dictionary = {}

@onready var _shop_items_grid: GridContainer = $ShopItemsMargin/ShopItemsScroll/ShopItemsGrid
@onready var _purchase_confirmation_popup: PopupPanel = $PurchaseConfirmationPopup
@onready var _notification_timer: Timer = $NotificationTimer
@onready var _notification_label: Label = $NotificationMargin/NotificationLabel
@onready var _money_label: Label = $MoneyMargin/MoneyLabel
@onready var _owned_items_grid: GridContainer = $OwnedItemsMargin/OwnedItemsScroll/OwnedItemsGrid
@onready var _stats_informations: Informations = $StatsMargin/StatsInformations


# PackedScene = le type Godot qui représente "un fichier .tscn chargé en mémoire, prêt à être dupliqué (instancié)"
# preaload pour charger la scène directement à la compilation et pas à l'éxecution
const ITEM_BUTTON_SCENE: PackedScene = preload("res://ui/item_button.tscn")
const OWNED_ITEM_SLOT_SCENE: PackedScene = preload("res://ui/owned_item_slot.tscn")

func _ready() -> void:
	_money_label.text = str(_current_money) + "$"
	for item in _available_items:
		var button: ItemButton = ITEM_BUTTON_SCENE.instantiate()
		_shop_items_grid.add_child(button)
		# appel de setup() dans item_button.gd qui remplie le bouton d'un item et d'un text
		button.setup(item)
		# quand le signal du bouton est déclanché = connexion à on_item_selected()
		button.item_selected.connect(_on_item_selected)
		
		
	_purchase_confirmation_popup.purchase_confirmed.connect(_on_purchase_confirmed)
	_notification_timer.timeout.connect(_on_notification_timeout)

# Donne au shop les données du joueur, à appeler à l'ouverture du shop.
# money : argent du joueur
# owned_items : Item -> quantité possédée
# stats : StatType.Type -> valeur (jauges et multiplicateurs)
func setup(money: int, owned_items: Dictionary, stats: Dictionary) -> void:
	_current_money = money
	_money_label.text = str(_current_money) + "$"

	# on retire les slots de l'ancien inventaire avant d'afficher le nouveau
	for item in _owned_panels:
		_owned_panels[item].queue_free()
	_owned_panels.clear()
	_owned_items.clear()
	for item in owned_items:
		_create_owned_slot(item)
		_owned_items[item] = owned_items[item]
		_owned_panels[item].set_amount(_owned_items[item])

	_stats_informations.set_values(stats)

func get_money() -> int:
	return _current_money

# Item -> quantité possédée (copie : la modifier ne change pas le shop)
func get_owned_items() -> Dictionary:
	return _owned_items.duplicate()

func _on_item_selected(item: Item) -> void:
	_purchase_confirmation_popup.show_item(item, _stats_informations, _owned_items.get(item, 0))
	
func _on_purchase_confirmed(item: Item, quantity: int) -> void:
	if quantity == 0:
		return
	# on regarde d'abord si on peut faire l'achat
	var total_price: int = quantity * int(item.get_price())
	if total_price > _current_money:
		_notification_label.add_theme_color_override("font_color", Color(0.962, 0.0, 0.0, 1.0))
		_show_notification("Pas assez d'argent !")
		return
	
	# si oui, on regarde ce qui sera réélement débité on fonction de la limite obtenable de l'item
	var added_quantity: int = _add_owned_item(item, quantity)
	if added_quantity == 0:
		return

	_current_money -= added_quantity * int(item.get_price())
	_money_label.text = str(_current_money) + "$"

	# chaque exemplaire réellement acheté applique son bonus à la jauge correspondante
	for modifier in item.get_stat_modifiers():
		_stats_informations.add_stat(modifier.get_stat_type(), modifier.get_flat_bonus() * added_quantity)
		_stats_informations.add_multiplier(modifier.get_stat_type(), modifier.get_multiplier_bonus() * added_quantity)

	_notification_label.add_theme_color_override("font_color", Color(0.01, 0.82, 0.0, 1.0))

	if added_quantity < quantity:
		_show_notification("Seulement %d ajouté(s) (limite atteinte)" % added_quantity)
	else:
		_show_notification("Achat effectué !")

	# on avertis le joueur qu'il a acheté un item
	item_purchased.emit(item, added_quantity)
	
func _add_owned_item(item: Item, quantity: int) -> int:
	var current_amount: int = _owned_items.get(item, 0)
	var quantity_to_add: int = min(quantity, item.get_max_owned() - current_amount)

	if quantity_to_add <= 0:
		_notification_label.add_theme_color_override("font_color", Color(0.962, 0.0, 0.0, 1.0))
		_show_notification("Impossible d'en avoir plus !")
		return 0

	if not _owned_items.has(item):
		_create_owned_slot(item)

	_owned_items[item] = current_amount + quantity_to_add
	_owned_panels[item].set_amount(_owned_items[item])
	return quantity_to_add

# crée le slot d'un item dans la grille des objets possédés
func _create_owned_slot(item: Item) -> void:
	var panel: OwnedItemSlot = OWNED_ITEM_SLOT_SCENE.instantiate()
	panel.slot_clicked.connect(_on_owned_slot_clicked)
	panel.sell_confirmed.connect(_on_sell_confirmed)
	_owned_items_grid.add_child(panel)
	panel.setup(item)
	_owned_panels[item] = panel

func _on_owned_slot_clicked(item: Item) -> void:
	_owned_panels[item].open_sell_popup(_stats_informations)

func _on_sell_confirmed(item: Item, quantity: int) -> void:
	# un objet revendu ne rapporte qu'une partie de son prix (voir Item.get_sell_price())
	_current_money += quantity * int(item.get_sell_price())
	_money_label.text = str(_current_money) + "$"
	_notification_label.add_theme_color_override("font_color", Color(0.01, 0.82, 0.0, 1.0))
	_show_notification("Vente effectuée !")

	# on retire le bonus de chaque exemplaire vendu
	for modifier in item.get_stat_modifiers():
		_stats_informations.add_stat(modifier.get_stat_type(), -modifier.get_flat_bonus() * quantity)
		_stats_informations.add_multiplier(modifier.get_stat_type(), -modifier.get_multiplier_bonus() * quantity)

	_owned_items[item] -= quantity
	if _owned_items[item] <= 0:
		# plus aucun exemplaire : on retire le slot de la grille
		_owned_items.erase(item)
		_owned_panels[item].queue_free()
		_owned_panels.erase(item)
	else:
		_owned_panels[item].set_amount(_owned_items[item])

	# on avertis le joueur qu'il a vendu un item
	item_sold.emit(item, quantity)

func _show_notification(message : String) -> void:
	_notification_label.text = message
	_notification_label.visible = true
	_notification_timer.start(5)
	
func _on_notification_timeout() -> void:
	_notification_label.visible = false
