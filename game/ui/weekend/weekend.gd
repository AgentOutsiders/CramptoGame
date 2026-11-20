extends Control

const SHOP_PATH: String = "res://ui/shop/shop.tscn"

@onready var summary_label: Label = %SummaryLabel
@onready var shop_button: Button = %ShopButton
@onready var study_button: Button = %StudyButton
@onready var socialize_button: Button = %SocializeButton
@onready var rest_button: Button = %RestButton


func _ready() -> void:
	shop_button.pressed.connect(_on_shop_pressed)
	study_button.pressed.connect(_on_study_pressed)
	socialize_button.pressed.connect(_on_socialize_pressed)
	rest_button.pressed.connect(_on_rest_pressed)
	update_summary()


func update_summary() -> void:
	var text: String = "Semaine %d / Année %d\nArgent : %d $\n" % [
		GameManager.current_week,
		GameManager.current_year,
		GameManager.money
	]
	text += "Science : %d | Littérature : %d\n" % [
		int(GameManager.stats.get(StatType.Type.SCIENTIFIC, 0)),
		int(GameManager.stats.get(StatType.Type.LITERATURE, 0))
	]
	text += "Vie sociale : %d | Loisirs : %d\n" % [
		int(GameManager.stats.get(StatType.Type.SOCIAL_LIFE, 0)),
		int(GameManager.stats.get(StatType.Type.LEISURE, 0))
	]
	text += "Sommeil : x%.2f | Méthodologie : x%.2f | Assiduité : x%.2f" % [
		GameManager.stats.get(StatType.Type.SLEEP, 1.0),
		GameManager.stats.get(StatType.Type.METHODOLOGY, 1.0),
		GameManager.stats.get(StatType.Type.ATTENDANCE, 1.0)
	]
	summary_label.text = text


func apply_modifier(stat_type: StatType.Type, flat_bonus: int = 0, multiplier_bonus: float = 0.0) -> void:
	var modifier: StatModifier = StatModifier.new()
	modifier._stat_type = stat_type
	modifier._flat_bonus = flat_bonus
	modifier._multiplier_bonus = multiplier_bonus
	GameManager.apply_stat_modifier(modifier)


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file(SHOP_PATH)


func _on_study_pressed() -> void:
	apply_modifier(StatType.Type.SCIENTIFIC, 5)
	apply_modifier(StatType.Type.METHODOLOGY, 0, 0.05)
	if not GameManager.is_game_over:
		GameManager.start_next_week()


func _on_socialize_pressed() -> void:
	apply_modifier(StatType.Type.SOCIAL_LIFE, 8)
	apply_modifier(StatType.Type.LEISURE, 3)
	if not GameManager.is_game_over:
		GameManager.start_next_week()


func _on_rest_pressed() -> void:
	apply_modifier(StatType.Type.SLEEP, 0, 0.10)
	if not GameManager.is_game_over:
		GameManager.start_next_week()
