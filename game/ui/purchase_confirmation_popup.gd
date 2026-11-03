extends PopupPanel
class_name PurchaseConfirmationPopup

signal purchase_confirmed(item: Item, quantity: int)

var _item: Item
var _quantity: int = 1
# nombre d'exemplaires qu'on peut encore acheter (maximum de l'item - exemplaires déjà possédés)
var _max_quantity: int = 0
@onready var _title_label: Label = $ContentVBox/TitleLabel
@onready var _description_label: Label = $ContentVBox/DescriptionLabel
@onready var _bonuses_label: Label = $ContentVBox/BottomHBox/DetailsVBox/BonusesLabel
@onready var _max_quantity_label: Label = $ContentVBox/BottomHBox/DetailsVBox/MaxQuantityLabel
@onready var _quantity_label: Label = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/QuantityLabel
@onready var _up_arrow_button: Button = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/ArrowsVBox/UpArrowButton
@onready var _down_arrow_button: Button = $ContentVBox/BottomHBox/DetailsVBox/QuantityHBox/ArrowsVBox/DownArrowButton
@onready var _purchase_button: Button = $ContentVBox/BottomHBox/DetailsVBox/ActionsHBox/PurchaseButton
@onready var _cancel_button: Button = $ContentVBox/BottomHBox/DetailsVBox/ActionsHBox/CancelButton
# récap des stats en bas à droite : copie des stats du shop, avec l'aperçu de l'achat qui clignote
@onready var _stats_informations: Informations = $ContentVBox/BottomHBox/StatsPanel/StatsInformations


# current_stats : le panneau de stats du shop, recopié dans le récap du popup
# owned_amount : nombre d'exemplaires de l'item déjà possédés
func show_item(item: Item, current_stats: Informations, owned_amount: int) -> void:
	_item = item
	_max_quantity = max(0, item.get_max_owned() - owned_amount)
	_quantity = min(1, _max_quantity)
	# rien à acheter si on a déjà le maximum
	_purchase_button.disabled = _max_quantity == 0
	_title_label.text = item.get_item_name()
	_description_label.text = item.get_display_description()
	# sans description, le label est caché : il ne prend plus de place et le titre se recentre tout seul
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
	#on utilise connect pour connecter des signaux à des fonctions
	_purchase_button.pressed.connect(_on_confirm_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	_up_arrow_button.pressed.connect(_on_up_arrow_pressed)
	_down_arrow_button.pressed.connect(_on_down_arrow_pressed)
	#popup_hide = signal de la classe PopUp
	popup_hide.connect(_on_popup_hide)

# affiche la quantité et met à jour l'aperçu des stats en fonction d'elle
func _update_quantity() -> void:
	_quantity_label.text = str(_quantity)
	_stats_informations.show_preview(_item.get_stat_modifiers(), _quantity)

func _on_confirm_pressed() -> void:
	purchase_confirmed.emit(_item, _quantity)
	hide()

func _on_cancel_pressed() -> void:
	hide()

func _on_popup_hide() -> void:
	# arrête le clignotement tant que le popup est fermé
	_stats_informations.clear_preview()

func _on_up_arrow_pressed() -> void:
	_quantity = min(_max_quantity, _quantity + 1)
	_update_quantity()

func _on_down_arrow_pressed() -> void:
	_quantity = max(min(1, _max_quantity), _quantity - 1)
	_update_quantity()
