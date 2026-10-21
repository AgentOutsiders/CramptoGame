extends PopupPanel
class_name PurchaseConfirmationPopup

signal purchase_confirmed(item: Item, quantity: int)

var _item: Item
@onready var _title_label: Label = $ContentVBox/TitleLabel
@onready var _purchase_button: Button = $ContentVBox/ActionsHBox/PurchaseButton
@onready var _cancel_button: Button = $ContentVBox/ActionsHBox/CancelButton
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _up_arrow_button: Button = $ContentVBox/QuantityHBox/ArrowsVBox/UpArrowButton
@onready var _down_arrow_button: Button = $ContentVBox/QuantityHBox/ArrowsVBox/DownArrowButton
@onready var _quantity_label: Label = $ContentVBox/QuantityHBox/QuantityLabel
@onready var _max_quantity_label: Label = $ContentVBox/MaxQuantityLabel


# top_right : point (en coordonnées globales) où sera placé le coin haut-droit du popup
func show_item(item: Item, top_right: Vector2) -> void:
	_item = item
	_title_label.text = item._name

	_max_quantity_label.text = "Maximum obtenable : " + str(_item._max_owned)
	var stats_text: String = ""
	for modifier in item._stat_modifiers:
		stats_text += modifier.display_text() + "\n"
	_description_label.text = "%s\n\n%s" % [item._description, stats_text]

	# popup() d'abord : le popup peut s'agrandir à l'affichage pour contenir son texte,
	# on le place ensuite avec sa taille définitive
	popup()
	position = Vector2i(top_right) - Vector2i(size.x, 0)

func _ready() -> void:
	#on utilise connect pour connecter des signaux à des fonctions
	_purchase_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_up_arrow_button.pressed.connect(_on_up_arrow_pressed)
	_down_arrow_button.pressed.connect(_on_down_arrow_pressed)
	#popup_hide = signal de la classe PopUp
	popup_hide.connect(_on_popup_hide)
	
func _on_confirm_pressed() -> void:
	purchase_confirmed.emit(_item,int(_quantity_label.text))
	_quantity_label.text = str(1)
	hide()

func _on_cancel_pressed() -> void:
	_quantity_label.text = str(1)
	hide()
	
func _on_popup_hide() -> void:
	_quantity_label.text = str(1)
	
func _on_up_arrow_pressed() -> void:
	var temp: int = int(_quantity_label.text)
	_quantity_label.text = str(min(10, temp + 1 ))

func _on_down_arrow_pressed() -> void:
	var temp: int = int(_quantity_label.text)
	_quantity_label.text = str(max(1, temp - 1))
	
	
	
