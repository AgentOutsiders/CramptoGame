extends PopupPanel
class_name PurchaseConfirmationPopup

signal purchase_confirmed(item: Item, quantity: int)

# number of blinks of the maximum label when the limit is reached, and duration of one way
const LIMIT_BLINK_COUNT: int = 3
const LIMIT_BLINK_DURATION: float = 0.15

var _item: Item
var _quantity: int = 1
# number of copies that can still be bought (item maximum - copies already owned)
var _max_quantity: int = 0
# blinking of the maximum label, kept to stop it if the arrow is pressed again
var _limit_blink_tween: Tween
@onready var _title_label: Label = $ContentVBox/TitleLabel
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _bonuses_label: Label = $ContentVBox/BottomHBox/DetailsVBox/BonusesLabel
@onready var _max_quantity_label: Label = $ContentVBox/BottomHBox/DetailsVBox/MaxQuantityLabel
@onready var _quantity_label: Label = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/QuantityLabel
@onready var _up_arrow_button: Button = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/ArrowsVBox/UpArrowButton
@onready var _down_arrow_button: Button = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/ArrowsVBox/DownArrowButton
@onready var _purchase_button: Button = $ContentVBox/BottomHBox/DetailsVBox/ActionsHBox/PurchaseButton
@onready var _cancel_button: Button = $ContentVBox/BottomHBox/DetailsVBox/ActionsHBox/CancelButton
# stats recap at the bottom right: copy of the shop's stats, with the purchase preview blinking
@onready var _stats_informations: Informations = $ContentVBox/BottomHBox/StatsPanel/StatsInformations


# current_stats: the shop's stats panel, copied into the popup's recap
# owned_amount: number of copies of the item already owned
func show_item(item: Item, current_stats: Informations, owned_amount: int) -> void:
	_item = item
	_max_quantity = max(0, item.get_max_owned() - owned_amount)
	_quantity = min(1, _max_quantity)
	# nothing to buy if the maximum is already owned
	_purchase_button.disabled = _max_quantity == 0
	_title_label.text = item.get_item_name()
	_description_label.text = item.get_display_description()
	# without a description, the label is hidden: it takes no space and the title recenters by itself
	_description_label.visible = _description_label.text != ""

	var bonuses_text: String = ""
	for modifier in item.get_stat_modifiers():
		bonuses_text += modifier.display_text() + "\n"
	_bonuses_label.text = bonuses_text.strip_edges()
	_max_quantity_label.text = "Maximum : %d\nDéjà possédé : %d" % [item.get_max_owned(), owned_amount]

	_stats_informations.copy_from(current_stats)
	_update_quantity()
	popup_centered()

func _ready() -> void:
	# connect is used to connect signals to functions
	_purchase_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_up_arrow_button.pressed.connect(_on_up_arrow_pressed)
	_down_arrow_button.pressed.connect(_on_down_arrow_pressed)
	# popup_hide = signal of the Popup class
	popup_hide.connect(_on_popup_hide)

# shows the quantity and updates the stats preview according to it
func _update_quantity() -> void:
	_quantity_label.text = str(_quantity)
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

func _on_up_arrow_pressed() -> void:
	if _quantity >= _max_quantity:
		# already at the limit: the maximum label blinks to show why the quantity does not go up
		_blink_limit()
		return
	_quantity += 1
	_update_quantity()

# makes the maximum label blink LIMIT_BLINK_COUNT times
func _blink_limit() -> void:
	_stop_limit_blink()
	_limit_blink_tween = create_tween().set_loops(LIMIT_BLINK_COUNT)
	# modulate:a = opacity of the label, it goes from 1 to 0.2 then back to 1
	_limit_blink_tween.tween_property(_max_quantity_label, "modulate:a", 0.2, LIMIT_BLINK_DURATION)
	_limit_blink_tween.tween_property(_max_quantity_label, "modulate:a", 1.0, LIMIT_BLINK_DURATION)

# stops the blinking and makes the label fully visible again
func _stop_limit_blink() -> void:
	if _limit_blink_tween:
		_limit_blink_tween.kill()
	_max_quantity_label.modulate.a = 1.0

func _on_down_arrow_pressed() -> void:
	_quantity = max(min(1, _max_quantity), _quantity - 1)
	_update_quantity()
