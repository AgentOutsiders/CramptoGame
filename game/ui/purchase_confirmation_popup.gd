extends PopupPanel
class_name PurchaseConfirmationPopup

signal purchase_confirmed(item: Item)

var _item: Item
@onready var _popup_title: Label = $Content/PopupTitle
@onready var _confirm_purchase: Button = $Content/Buttons/ConfirmPurchase
@onready var _cancel_purchase: Button = $Content/Buttons/CancelPurchase
@onready var _popup_description: Label = $Content/PopupDescription

func show_item(item: Item) -> void:
	_item = item
	_popup_title.text = item._name

	var stats_text: String = ""
	for modifier in item._stat_modifiers:
		# .keys() est une méthode qui retourne la liste des noms de l'enum sous forme de strings, dans l'ordre de déclaration
		var stat_name: String = StatType.Type.keys()[modifier._stat_type]
		stats_text += "%s : %+d\n" % [stat_name, modifier._flat_bonus]
	_popup_description.text = "\n%s\n\n%s" % [item._description, stats_text]
	
	popup_centered()

func _on_confirmed() -> void:
	purchase_confirmed.emit(_item)
	
func _ready() -> void:
	#on utilise connect pour connecter des signaux à des fonctions
	_confirm_purchase.pressed.connect(_on_confirm_pressed)
	_cancel_purchase.pressed.connect(_on_cancel_pressed)

func _on_confirm_pressed() -> void:
	purchase_confirmed.emit(_item)
	hide()

func _on_cancel_pressed() -> void:
	hide()
	
