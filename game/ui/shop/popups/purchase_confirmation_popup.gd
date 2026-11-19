extends PopupPanel
class_name PurchaseConfirmationPopup

signal purchase_confirmed(item: Item, quantity: int)

# number of blinks of the owned label when the limit is reached, and duration of one way
const LIMIT_BLINK_COUNT: int = 3
const LIMIT_BLINK_DURATION: float = 0.15

var _item: Item
var _quantity: int = 1
# number of copies that can still be bought (item maximum - copies already owned)
var _max_quantity: int = 0
# blinking of the owned label, kept to stop it if + is pressed again
var _limit_blink_tween: Tween
@onready var _icon_texture_rect: TextureRect = $ContentVBox/HeaderHBox/IconTextureRect
@onready var _title_label: Label = $ContentVBox/HeaderHBox/TitleLabel
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _owned_label: Label = $ContentVBox/OwnedLabel
@onready var _quantity_label: Label = $ContentVBox/QuantityHBox/QuantityLabel
@onready var _minus_button: Button = $ContentVBox/QuantityHBox/MinusButton
@onready var _plus_button: Button = $ContentVBox/QuantityHBox/PlusButton
@onready var _total_label: Label = $ContentVBox/QuantityHBox/TotalLabel
@onready var _purchase_button: Button = $ContentVBox/ActionsHBox/PurchaseButton
@onready var _cancel_button: Button = $ContentVBox/ActionsHBox/CancelButton
# stats recap in the middle: copy of the shop's stats, with the purchase preview blinking
@onready var _stats_informations: Informations = $ContentVBox/StatsPanel/StatsInformations


# current_stats: the shop's stats panel, copied into the popup's recap
# owned_amount: number of copies of the item already owned
func show_item(item: Item, current_stats: Informations, owned_amount: int) -> void:
	_item = item
	_max_quantity = max(0, item.get_max_owned() - owned_amount)
	_quantity = min(1, _max_quantity)
	# nothing to buy if the maximum is already owned
	_purchase_button.disabled = _max_quantity == 0
	_icon_texture_rect.texture = item.get_texture()
	_title_label.text = item.get_item_name()
	# Small yellow hint when the item can be used in events
	_description_label.text = item.get_display_description()
	# without a hint, the label is hidden so it takes no space
	_description_label.visible = _description_label.text != ""
	_owned_label.text = "Possédé : %d / %d" % [owned_amount, item.get_max_owned()]

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
	# When Acheter is clicked we confirm the purchase
	_purchase_button.pressed.connect(_on_confirm_pressed)
	# When Annuler is clicked we close the popup
	_cancel_button.pressed.connect(_on_cancel_pressed)
	# When + is clicked we add one to the quantity
	_plus_button.pressed.connect(_on_plus_pressed)
	# When - is clicked we remove one from the quantity
	_minus_button.pressed.connect(_on_minus_pressed)
	# When the popup closes we stop the stats preview
	popup_hide.connect(_on_popup_hide)

# Shows the quantity and the total price, and updates the stats preview
func _update_quantity() -> void:
	_quantity_label.text = str(_quantity)
	_total_label.text = "Total : %.0f $" % (_quantity * _item.get_price())
	# - is greyed out at the minimum, + stays active so the limit can blink
	_minus_button.disabled = _quantity <= min(1, _max_quantity)
	_stats_informations.show_preview(_item.get_stat_modifiers(), _quantity)

func _on_confirm_pressed() -> void:
	purchase_confirmed.emit(_item, _quantity)
	hide()

func _on_cancel_pressed() -> void:
	hide()

func _on_popup_hide() -> void:
	# stops the blinking while the popup is closed
	_stats_informations.clear_preview()
	_stop_limit_blink()

func _on_plus_pressed() -> void:
	if _quantity >= _max_quantity:
		# already at the limit: the owned label blinks to show why the quantity does not go up
		_blink_limit()
		return
	_quantity += 1
	_update_quantity()

# makes the owned label blink LIMIT_BLINK_COUNT times
func _blink_limit() -> void:
	_stop_limit_blink()
	_limit_blink_tween = create_tween().set_loops(LIMIT_BLINK_COUNT)
	# modulate:a = opacity of the label, it goes from 1 to 0.2 then back to 1
	_limit_blink_tween.tween_property(_owned_label, "modulate:a", 0.2, LIMIT_BLINK_DURATION)
	_limit_blink_tween.tween_property(_owned_label, "modulate:a", 1.0, LIMIT_BLINK_DURATION)

# stops the blinking and makes the label fully visible again
func _stop_limit_blink() -> void:
	if _limit_blink_tween:
		_limit_blink_tween.kill()
	_owned_label.modulate.a = 1.0

func _on_minus_pressed() -> void:
	_quantity = max(min(1, _max_quantity), _quantity - 1)
	_update_quantity()
