extends PopupPanel
class_name SellConfirmationPopup

signal sell_confirmed(item: Item, quantity: int)

@export var _expand_duration: float = 0.25

var _item: Item
var _amount : int
var _base_size: Vector2i
var _expand_tween: Tween
@onready var _title_label: Label = $ContentVBox/TitleLabel
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _sell_button: Button = $ContentVBox/ActionsHBox/SellButton
@onready var _back_button: Button = $ContentVBox/ActionsHBox/BackButton
# SellSectionControl est un simple Control qui coupe ce qui dépasse :
# on anime sa hauteur pour que les éléments au-dessus glissent au lieu de se téléporter
@onready var _sell_section_control: Control = $ContentVBox/SellSectionControl
@onready var _sell_section_vbox: VBoxContainer = $ContentVBox/SellSectionControl/SellSectionVBox
@onready var _up_arrow_button: Button = $ContentVBox/SellSectionControl/SellSectionVBox/QuantityHBox/ArrowsVBox/UpArrowButton
@onready var _down_arrow_button: Button = $ContentVBox/SellSectionControl/SellSectionVBox/QuantityHBox/ArrowsVBox/DownArrowButton
@onready var _quantity_label: Label = $ContentVBox/SellSectionControl/SellSectionVBox/QuantityHBox/QuantityLabel
@onready var _confirm_button: Button = $ContentVBox/SellSectionControl/SellSectionVBox/ConfirmButton

# top_right : point (en coordonnées globales) où sera placé le coin haut-droit du popup
func show_item(item: Item, amount: int, top_right: Vector2) -> void:
	_item = item
	_amount = amount
	_title_label.text = "%s (x%d)" % [item._name, amount]

	var stats_text: String = ""
	for modifier in item._stat_modifiers:
		stats_text += modifier.display_text() + "\n"
	_description_label.text = "\n%s\n\n%s" % [item._description, stats_text]

	# popup() d'abord : le popup peut s'agrandir à l'affichage pour contenir son texte,
	# on le place ensuite avec sa taille définitive
	popup()
	position = Vector2i(top_right) - Vector2i(size.x, 0)
	
func _ready() -> void:
	_sell_button.pressed.connect(_on_sell_item_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_up_arrow_button.pressed.connect(_on_up_arrow_pressed)
	_down_arrow_button.pressed.connect(_on_down_arrow_pressed)
	_confirm_button.pressed.connect(_on_confirm_button_pressed)
	#popup_hide = signal de la classe Popup, déclenché aussi quand on clique en dehors
	popup_hide.connect(_on_popup_hide)
	_base_size = size

func _on_sell_item_pressed() -> void:
	if _sell_section_vbox.visible:
		return
	_sell_section_vbox.visible = true
	var expand_height: float = _sell_section_vbox.get_combined_minimum_size().y

	# le popup et la section grandissent de la même hauteur en même temps (parallel) :
	# le contenu suit la bordure du haut et la section se dévoile par le bas
	_expand_tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_expand_tween.tween_method(_set_popup_height, size.y, _base_size.y + int(expand_height), _expand_duration)
	_expand_tween.tween_property(_sell_section_control, "custom_minimum_size:y", expand_height, _expand_duration)

# change la hauteur du popup en gardant son centre au même endroit, pour qu'il s'agrandisse vers le haut et le bas
func _set_popup_height(height: int) -> void:
	var center_y: float = position.y + size.y / 2.0
	size.y = height
	position.y = int(center_y - height / 2.0)

func _on_back_pressed() -> void:
	hide()

# remet le popup dans son état de départ pour la prochaine ouverture
func _on_popup_hide() -> void:
	if _expand_tween:
		_expand_tween.kill()
	_sell_section_vbox.visible = false
	_sell_section_control.custom_minimum_size.y = 0
	_quantity_label.text = str(1)
	size = _base_size

func _on_confirm_button_pressed() -> void:
	sell_confirmed.emit(_item, int(_quantity_label.text))
	_quantity_label.text = str(1)
	hide()

func _on_up_arrow_pressed() -> void:
	var temp: int = int(_quantity_label.text)
	# on ne peut pas vendre plus que ce qu'on possède
	_quantity_label.text = str(min(_amount, temp + 1))

func _on_down_arrow_pressed() -> void:
	var temp: int = int(_quantity_label.text)
	_quantity_label.text = str(max(1, temp - 1))
