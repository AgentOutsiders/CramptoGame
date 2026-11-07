extends Control
class_name Shop

# Signals to connect the shop with the player instance,
# emitted after a successful purchase or sale
# quantity = number of copies actually bought or sold
signal item_purchased(item: Item, quantity: int)
signal item_sold(item: Item, quantity: int)

@export var _available_items: Array[Item] = []
@export var _current_money: int = 100000
# Item -> quantity (int)
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


# PackedScene = the Godot type for "a .tscn file loaded in memory, ready to be duplicated (instantiated)"
# preload to load the scene at compile time and not at runtime
const ITEM_BUTTON_SCENE: PackedScene = preload("res://ui/item_button.tscn")
const OWNED_ITEM_SLOT_SCENE: PackedScene = preload("res://ui/owned_item_slot.tscn")

func _ready() -> void:
	_money_label.text = str(_current_money) + "$"
	for item in _available_items:
		var button: ItemButton = ITEM_BUTTON_SCENE.instantiate()
		_shop_items_grid.add_child(button)
		# calls setup() in item_button.gd, which fills the button with an item and a text
		button.setup(item)
		# when the button's signal is fired = connected to _on_item_selected()
		button.item_selected.connect(_on_item_selected)
		
		
	_purchase_confirmation_popup.purchase_confirmed.connect(_on_purchase_confirmed)
	_notification_timer.timeout.connect(_on_notification_timeout)

# Gives the player's data to the shop, to call when the shop opens.
# money: the player's money
# owned_items: Item -> quantity owned
# stats: StatType.Type -> value (gauges and multipliers)
func setup(money: int, owned_items: Dictionary, stats: Dictionary) -> void:
	_current_money = money
	_money_label.text = str(_current_money) + "$"

	# remove the slots of the old inventory before showing the new one
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

# Item -> quantity owned (copy: changing it does not change the shop)
func get_owned_items() -> Dictionary:
	return _owned_items.duplicate()

func _on_item_selected(item: Item) -> void:
	_purchase_confirmation_popup.show_item(item, _stats_informations, _owned_items.get(item, 0))
	
func _on_purchase_confirmed(item: Item, quantity: int) -> void:
	if quantity == 0:
		return
	# first check if the purchase is possible
	var total_price: int = quantity * int(item.get_price())
	if total_price > _current_money:
		_notification_label.add_theme_color_override("font_color", Color(0.962, 0.0, 0.0, 1.0))
		_show_notification("Pas assez d'argent !")
		return
	
	# if so, check what will really be charged according to the item's ownership limit
	var added_quantity: int = _add_owned_item(item, quantity)
	if added_quantity == 0:
		return

	_current_money -= added_quantity * int(item.get_price())
	_money_label.text = str(_current_money) + "$"

	# each copy actually bought applies its bonus to the matching gauge
	for modifier in item.get_stat_modifiers():
		_stats_informations.add_stat(modifier.get_stat_type(), modifier.get_flat_bonus() * added_quantity)
		_stats_informations.add_multiplier(modifier.get_stat_type(), modifier.get_multiplier_bonus() * added_quantity)

	_notification_label.add_theme_color_override("font_color", Color(0.01, 0.82, 0.0, 1.0))

	if added_quantity < quantity:
		_show_notification("Seulement %d ajouté(s) (limite atteinte)" % added_quantity)
	else:
		_show_notification("Achat effectué !")

	# notify the player that they bought an item
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

# creates the slot of an item in the owned items grid
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
	# a sold item only gives back part of its price (see Item.get_sell_price())
	_current_money += quantity * int(item.get_sell_price())
	_money_label.text = str(_current_money) + "$"
	_notification_label.add_theme_color_override("font_color", Color(0.01, 0.82, 0.0, 1.0))
	_show_notification("Vente effectuée !")

	# remove the bonus of each copy sold
	for modifier in item.get_stat_modifiers():
		_stats_informations.add_stat(modifier.get_stat_type(), -modifier.get_flat_bonus() * quantity)
		_stats_informations.add_multiplier(modifier.get_stat_type(), -modifier.get_multiplier_bonus() * quantity)

	_owned_items[item] -= quantity
	if _owned_items[item] <= 0:
		# no copy left: remove the slot from the grid
		_owned_items.erase(item)
		_owned_panels[item].queue_free()
		_owned_panels.erase(item)
	else:
		_owned_panels[item].set_amount(_owned_items[item])

	# notify the player that they sold an item
	item_sold.emit(item, quantity)

func _show_notification(message : String) -> void:
	_notification_label.text = message
	_notification_label.visible = true
	_notification_timer.start(5)
	
func _on_notification_timeout() -> void:
	_notification_label.visible = false
