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
	# on relaie le signal du popup vers le shop, qui est le seul à connaître l'argent
	_sell_confirmation_popup.sell_confirmed.connect(sell_confirmed.emit)
	
func setup(item: Item) -> void:
	_item = item
	_icon_texture_rect.texture = item._texture
	tooltip_text = "%s\nClic : informations" % item._name
	
func set_amount(amount : int) -> void:
	_amount = amount
	_amount_label.text = "x%d" % amount

#Le signal gui_input de Control se déclenche pour chaque événement souris reçu
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(_item)
		
# appelé par le shop au clic, car c'est lui qui connaît la mise en page et donc où placer le popup
func open_sell_popup(top_right: Vector2) -> void:
	_sell_confirmation_popup.show_item(_item, _amount, top_right)
	
		
