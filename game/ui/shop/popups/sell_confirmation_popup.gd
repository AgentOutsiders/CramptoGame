extends PopupPanel
class_name SellConfirmationPopup

signal sell_confirmed(item: Item, quantity: int)

var _item: Item
var _quantity: int = 1
# number of copies owned: you cannot sell more than that
var _owned_amount: int = 0
@onready var _title_label: Label = $ContentVBox/TitleLabel
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _bonuses_label: Label = $ContentVBox/BottomHBox/DetailsVBox/BonusesLabel
@onready var _owned_amount_label: Label = $ContentVBox/BottomHBox/DetailsVBox/OwnedAmountLabel
@onready var _quantity_label: Label = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/QuantityLabel
@onready var _up_arrow_button: Button = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/ArrowsVBox/UpArrowButton
@onready var _down_arrow_button: Button = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/ArrowsVBox/DownArrowButton
@onready var _sell_button: Button = $ContentVBox/BottomHBox/DetailsVBox/ActionsHBox/SellButton
@onready var _cancel_button: Button = $ContentVBox/BottomHBox/DetailsVBox/ActionsHBox/CancelButton
# stats recap at the bottom right: copy of the shop's stats, with the sale preview blinking
@onready var _stats_informations: Informations = $ContentVBox/BottomHBox/StatsPanel/StatsInformations


# owned_amount: number of copies of the item owned
# current_stats: the shop's stats panel, copied into the popup's recap
func show_item(item: Item, owned_amount: int, current_stats: Informations) -> void:
	_item = item
	_owned_amount = owned_amount
	_quantity = min(1, _owned_amount)
	_sell_button.disabled = _owned_amount == 0
	_title_label.text = item.get_item_name()
	_description_label.text = item.get_display_description()
	# without a description, the label is hidden: it takes no space and the title recenters by itself
	_description_label.visible = _description_label.text != ""

	var bonuses_text: String = ""
	for modifier in item.get_stat_modifiers():
		bonuses_text += modifier.display_text() + "\n"
	_bonuses_label.text = bonuses_text.strip_edges()

	_stats_informations.copy_from(current_stats)
	_update_quantity()
	popup_centered()

func _ready() -> void:
	_sell_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_up_arrow_button.pressed.connect(_on_up_arrow_pressed)
	_down_arrow_button.pressed.connect(_on_down_arrow_pressed)
	# popup_hide = signal of the Popup class, also fired when clicking outside
	popup_hide.connect(_on_popup_hide)

# shows the quantity and updates the stats preview according to it
# (negative quantity: the preview shows what will be lost, in red)
func _update_quantity() -> void:
	_quantity_label.text = str(_quantity)
	# money given back for the chosen quantity (same calculation as in the shop)
	var sell_total: int = _quantity * int(_item.get_sell_price())
	_owned_amount_label.text = "Possédé : %d\nRevente : %d $" % [_owned_amount, sell_total]
	_stats_informations.show_preview(_item.get_stat_modifiers(), -_quantity)

func _on_confirm_pressed() -> void:
	sell_confirmed.emit(_item, _quantity)
	hide()

func _on_cancel_pressed() -> void:
	hide()

func _on_popup_hide() -> void:
	# stops the blinking while the popup is closed
	_stats_informations.clear_preview()

func _on_up_arrow_pressed() -> void:
	# you cannot sell more than what you own
	_quantity = min(_owned_amount, _quantity + 1)
	_update_quantity()

func _on_down_arrow_pressed() -> void:
	_quantity = max(min(1, _owned_amount), _quantity - 1)
	_update_quantity()
