extends VBoxContainer
class_name OwnedItemSlot

@onready var _icon_texture_rect: TextureRect = $IconPanel/IconMargin/IconTextureRect
@onready var _amount_label: Label = $AmountLabel
@onready var _sell_confirmation_popup: SellConfirmationPopup = $SellConfirmationPopup

var _item: Item
var _amount: int = 0

signal slot_clicked(item: Item)
signal sell_confirmed(item: Item, quantity: int)

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	# forwards the popup's signal to the shop, which is the only one that knows the money
	_sell_confirmation_popup.sell_confirmed.connect(sell_confirmed.emit)
	
func setup(item: Item) -> void:
	_item = item
	_icon_texture_rect.texture = item.get_texture()
	tooltip_text = "%s\nClic : informations" % item.get_item_name()
	
func set_amount(amount : int) -> void:
	_amount = amount
	_amount_label.text = "x%d" % amount

# The gui_input signal of Control fires for each mouse event received
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(_item)
		
# called by the shop when the slot is clicked
# current_stats: the shop's stats panel, shown as a recap in the popup
func open_sell_popup(current_stats: Informations) -> void:
	_sell_confirmation_popup.show_item(_item, _amount, current_stats)
	
		
