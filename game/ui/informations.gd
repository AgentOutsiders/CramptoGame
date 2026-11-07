extends VBoxContainer
class_name Informations

# les jauges vont de 0 à 100, les multiplicateurs de MIN_MULTIPLIER à MAX_MULTIPLIER
const MIN_MULTIPLIER: float = 0.5
const MAX_MULTIPLIER: float = 2.0
# durée d'un aller (ou d'un retour) du clignotement de l'aperçu
const PREVIEW_BLINK_DURATION: float = 0.5
# couleur de la partie d'une jauge qui sera perdue (aperçu d'une vente)
const PREVIEW_LOSS_COLOR: Color = Color(0.9, 0.2, 0.2)

@export var _bar_animation_duration: float = 0.4
# Largeur minimale des labels de valeur (0 = pas de minimum).
# Dans les popups, on la règle dans l'inspecteur pour que "100 → 100" tienne :
# le panneau ne change alors pas de taille pendant l'aperçu.
@export var _percent_label_min_width: float = 0
@export var _multiplier_label_min_width: float = 0

# jauge de chaque stat
@onready var _bars: Dictionary = {
	StatType.Type.SCIENTIFIC: $StatsVBox/StatsGrid/ScienceProgressBar,
	StatType.Type.LITERATURE: $StatsVBox/StatsGrid/LiteratureProgressBar,
	StatType.Type.SOCIAL_LIFE: $StatsVBox/StatsGrid/SocialLifeProgressBar,
	StatType.Type.LEISURE: $StatsVBox/StatsGrid/HobbyProgressBar,
}
# label qui affiche la valeur de chaque stat (jauges et multiplicateurs)
@onready var _labels: Dictionary = {
	StatType.Type.SCIENTIFIC: $StatsVBox/StatsGrid/SciencePercentLabel,
	StatType.Type.LITERATURE: $StatsVBox/StatsGrid/LiteraturePercentLabel,
	StatType.Type.SOCIAL_LIFE: $StatsVBox/StatsGrid/SocialLifePercentLabel,
	StatType.Type.LEISURE: $StatsVBox/StatsGrid/HobbyPercentLabel,
	StatType.Type.METHODOLOGY: $MultipliersVBox/MultipliersGrid/MethodologyValueLabel,
	StatType.Type.ATTENDANCE: $MultipliersVBox/MultipliersGrid/AttendanceValueLabel,
	StatType.Type.SLEEP: $MultipliersVBox/MultipliersGrid/SleepValueLabel,
}

# valeur de chaque stat : StatType.Type -> float
var _values: Dictionary = {}
# animations et jauges de fond créées pour l'aperçu, supprimées quand on l'efface
var _preview_tweens: Array[Tween] = []
var _preview_bars: Array[ProgressBar] = []

func _ready() -> void:
	for type in _labels:
		if StatType.is_multiplier(type):
			_labels[type].custom_minimum_size.x = _multiplier_label_min_width
		else:
			_labels[type].custom_minimum_size.x = _percent_label_min_width
	# valeurs de test, remplacées par celles du joueur avec set_values() (voir Shop.setup())
	set_stats(65, 40, 80, 25)
	set_multipliers(1.2, 0.8, 1.5)

func set_stats(science: float, literature: float, social_life: float, hobby: float) -> void:
	_values[StatType.Type.SCIENTIFIC] = science
	_values[StatType.Type.LITERATURE] = literature
	_values[StatType.Type.SOCIAL_LIFE] = social_life
	_values[StatType.Type.LEISURE] = hobby
	_update_bars()

func set_multipliers(methodology: float, attendance: float, sleep: float) -> void:
	_values[StatType.Type.METHODOLOGY] = clampf(methodology, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_values[StatType.Type.ATTENDANCE] = clampf(attendance, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_values[StatType.Type.SLEEP] = clampf(sleep, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_update_multipliers()

# remplace les valeurs des stats données : StatType.Type -> valeur
func set_values(values: Dictionary) -> void:
	for type in values:
		_values[type] = values[type]
	_update_bars()
	_update_multipliers()

# valeur actuelle d'une stat (jauge ou multiplicateur)
func get_stat(type: StatType.Type) -> float:
	return _values[type]

# Ajoute amount à la jauge de la stat (une valeur négative la fait baisser), avec une animation
func add_stat(type: StatType.Type, amount: float) -> void:
	if not _bars.has(type):
		# les autres stats sont des multiplicateurs, elles n'ont pas de jauge
		return
	_values[type] = clampf(_values[type] + amount, 0, 100)
	_labels[type].text = "%d" % _values[type]
	var tween: Tween = create_tween()
	tween.tween_property(_bars[type], "value", _values[type], _bar_animation_duration)

# Ajoute amount au multiplicateur de la stat (une valeur négative le fait baisser)
func add_multiplier(type: StatType.Type, amount: float) -> void:
	if not StatType.is_multiplier(type):
		# les autres stats ont une jauge, pas de multiplicateur
		return
	_values[type] = clampf(_values[type] + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_update_multipliers()

# recopie toutes les valeurs d'un autre panneau (ex : celui du shop vers celui d'un popup)
func copy_from(other: Informations) -> void:
	for type in _values:
		_values[type] = other.get_stat(type)
	clear_preview()

# Montre ce que count exemplaires de l'item changeraient, sans rien modifier pour de vrai.
# count est négatif pour une vente.
func show_preview(modifiers: Array[StatModifier], count: int) -> void:
	clear_preview()
	for modifier in modifiers:
		var type: StatType.Type = modifier.get_stat_type()
		if StatType.is_multiplier(type):
			_preview_multiplier(type, modifier.get_multiplier_bonus() * count)
		else:
			_preview_bar(type, modifier.get_flat_bonus() * count)

# arrête l'aperçu et réaffiche les vraies valeurs
func clear_preview() -> void:
	for tween in _preview_tweens:
		tween.kill()
	_preview_tweens.clear()
	for preview_bar in _preview_bars:
		preview_bar.queue_free()
	_preview_bars.clear()
	_update_bars()
	_update_multipliers()

# Aperçu d'une jauge : la jauge affiche la plus petite des deux valeurs, et une 2e jauge
# dessinée derrière elle affiche la plus grande. Seule la différence dépasse, et elle clignote.
func _preview_bar(type: StatType.Type, amount: float) -> void:
	var current: float = _values[type]
	var target: float = clampf(current + amount, 0, 100)
	if target == current:
		return
	_labels[type].text = "%d → %d" % [current, target]

	var bar: ProgressBar = _bars[type]
	bar.value = min(current, target)

	var preview_bar: ProgressBar = ProgressBar.new()
	preview_bar.value = max(current, target)
	preview_bar.show_percentage = false
	# show_behind_parent : la 2e jauge est dessinée derrière la vraie, pas par-dessus
	preview_bar.show_behind_parent = true
	# pas de fond, sinon il cacherait la vraie jauge
	preview_bar.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	# même remplissage que la vraie jauge (copié avec duplicate), en rouge si c'est une perte
	var fill: StyleBoxFlat = bar.get_theme_stylebox("fill").duplicate()
	if target < current:
		fill.bg_color = PREVIEW_LOSS_COLOR
	preview_bar.add_theme_stylebox_override("fill", fill)
	bar.add_child(preview_bar)
	# la 2e jauge prend exactement la taille de la vraie
	preview_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_preview_bars.append(preview_bar)

	# modulate:a = opacité de la 2e jauge, elle passe de 1 à 0.2 puis revient à 1, en boucle
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(preview_bar, "modulate:a", 0.2, PREVIEW_BLINK_DURATION)
	tween.tween_property(preview_bar, "modulate:a", 1.0, PREVIEW_BLINK_DURATION)
	_preview_tweens.append(tween)

# Aperçu d'un multiplicateur : le label affiche "avant → après" et clignote
func _preview_multiplier(type: StatType.Type, amount: float) -> void:
	var current: float = _values[type]
	var target: float = clampf(current + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
	if target == current:
		return
	_labels[type].text = "%s → %s" % [_format_multiplier(current), _format_multiplier(target)]

	# modulate:a = opacité du label, elle passe de 1 à 0.2 puis revient à 1, en boucle
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(_labels[type], "modulate:a", 0.2, PREVIEW_BLINK_DURATION)
	tween.tween_property(_labels[type], "modulate:a", 1.0, PREVIEW_BLINK_DURATION)
	_preview_tweens.append(tween)

# affiche la valeur de chaque jauge, sans animation
func _update_bars() -> void:
	for type in _bars:
		_bars[type].value = _values[type]
		_labels[type].text = "%d" % _values[type]

# affiche la valeur de chaque multiplicateur
func _update_multipliers() -> void:
	for type in [StatType.Type.METHODOLOGY, StatType.Type.ATTENDANCE, StatType.Type.SLEEP]:
		_labels[type].text = _format_multiplier(_values[type])
		_labels[type].modulate.a = 1.0

# ex : 1.2 -> "x1,20" (%.2f écrit un point, on le remplace par une virgule pour l'affichage en français)
func _format_multiplier(value: float) -> String:
	return ("x%.2f" % value).replace(".", ",")
