extends PopupPanel
class_name SellConfirmationPopup

signal sell_confirmed(item: Item, quantity: int)

var _item: Item
var _quantity: int = 1
# number of copies owned: you cannot sell more than that
var _owned_amount: int = 0
@onready var _icon_texture_rect: TextureRect = $ContentVBox/HeaderHBox/IconTextureRect
@onready var _title_label: Label = $ContentVBox/HeaderHBox/TitleLabel
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _owned_label: Label = $ContentVBox/OwnedLabel
@onready var _quantity_label: Label = $ContentVBox/QuantityHBox/QuantityLabel
@onready var _minus_button: Button = $ContentVBox/QuantityHBox/MinusButton
@onready var _plus_button: Button = $ContentVBox/QuantityHBox/PlusButton
@onready var _total_label: Label = $ContentVBox/QuantityHBox/TotalLabel
@onready var _sell_button: Button = $ContentVBox/ActionsHBox/SellButton
@onready var _cancel_button: Button = $ContentVBox/ActionsHBox/CancelButton
# stats recap in the middle: copy of the shop's stats, with the sale preview blinking
@onready var _stats_informations: Informations = $ContentVBox/StatsPanel/StatsInformations


# owned_amount: number of copies of the item owned
# current_stats: the shop's stats panel, copied into the popup's recap
func show_item(item: Item, owned_amount: int, current_stats: Informations) -> void:
	_item = item
	_owned_amount = owned_amount
	_quantity = min(1, _owned_amount)
	# nothing to sell if no copy is owned
	_sell_button.disabled = _owned_amount == 0
	_icon_texture_rect.texture = item.get_texture()
	_title_label.text = item.get_item_name()
	# Small yellow hint when the item can be used in events
	_description_label.text = item.get_display_description()
	# without a hint, the label is hidden so it takes no space
	_description_label.visible = _description_label.text != ""
	_owned_label.text = "Possédé : %d" % _owned_amount

	_stats_informations.copy_from(current_stats)
	_update_quantity()
	# Shrink the popup to its content so no empty space stays at the bottom
	reset_size()
	popup_centered()
	# On the first opening the texts are measured only after one frame
	# so we shrink and center the popup again once they are ready
	await get_tree().process_frame
	reset_size()
	popup_centered()

func _ready() -> void:
	# When Vendre is clicked we confirm the sale
	_sell_button.pressed.connect(_on_confirm_pressed)
	# When Annuler is clicked we close the popup
	_cancel_button.pressed.connect(_on_cancel_pressed)
	# When + is clicked we add one to the quantity
	_plus_button.pressed.connect(_on_plus_pressed)
	# When - is clicked we remove one from the quantity
	_minus_button.pressed.connect(_on_minus_pressed)
	# When the popup closes, also by clicking outside, we stop the stats preview
	popup_hide.connect(_on_popup_hide)

# Shows the quantity and the money given back, and updates the stats preview
# The quantity is negative in the preview so it shows in red what will be lost
func _update_quantity() -> void:
	_quantity_label.text = str(_quantity)
	# money given back for the chosen quantity (same calculation as in the shop)
	var sell_total: int = _quantity * int(_item.get_sell_price())
	_total_label.text = "Revente : %d $" % sell_total
	# the buttons are greyed out when the quantity can not go further
	_minus_button.disabled = _quantity <= min(1, _owned_amount)
	_plus_button.disabled = _quantity >= _owned_amount
	_stats_informations.show_preview(_item.get_stat_modifiers(), -_quantity)

func _on_confirm_pressed() -> void:
	sell_confirmed.emit(_item, _quantity)
	hide()

func _on_cancel_pressed() -> void:
	hide()

func _on_popup_hide() -> void:
	# stops the blinking while the popup is closed
	_stats_informations.clear_preview()

func _on_plus_pressed() -> void:
	# you cannot sell more than what you own
	_quantity = min(_owned_amount, _quantity + 1)
	_update_quantity()

func _on_minus_pressed() -> void:
	_quantity = max(min(1, _owned_amount), _quantity - 1)
	_update_quantity()
