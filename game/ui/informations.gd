extends VBoxContainer
class_name Informations

const MIN_MULTIPLIER: float = 0.5
const MAX_MULTIPLIER: float = 2.0

@onready var _science_progress_bar: ProgressBar = $StatsVBox/StatsGrid/ScienceProgressBar
@onready var _literature_progress_bar: ProgressBar = $StatsVBox/StatsGrid/LiteratureProgressBar
@onready var _social_life_progress_bar: ProgressBar = $StatsVBox/StatsGrid/SocialLifeProgressBar
@onready var _hobby_progress_bar: ProgressBar = $StatsVBox/StatsGrid/HobbyProgressBar

@onready var _science_percent_label: Label = $StatsVBox/StatsGrid/SciencePercentLabel
@onready var _literature_percent_label: Label = $StatsVBox/StatsGrid/LiteraturePercentLabel
@onready var _social_life_percent_label: Label = $StatsVBox/StatsGrid/SocialLifePercentLabel
@onready var _hobby_percent_label: Label = $StatsVBox/StatsGrid/HobbyPercentLabel

@onready var _methodology_value_label: Label = $MultipliersVBox/MultipliersGrid/MethodologyValueLabel
@onready var _attendance_value_label: Label = $MultipliersVBox/MultipliersGrid/AttendanceValueLabel
@onready var _sleep_value_label: Label = $MultipliersVBox/MultipliersGrid/SleepValueLabel

# valeurs des multiplicateurs, toujours entre MIN_MULTIPLIER et MAX_MULTIPLIER (comme les jauges entre 0 et 100)
@export var _bar_animation_duration: float = 0.4

# ProgressBar -> valeur finale visée par l'animation en cours
# (si on achète deux fois vite, le 2e ajout part de la valeur finale et pas de la valeur à mi-animation)
var _bar_targets: Dictionary = {}
# ProgressBar -> Tween en cours, pour pouvoir l'arrêter si un nouvel ajout arrive
var _bar_tweens: Dictionary = {}

var _methodology: float = 1.0
var _attendance: float = 1.0
var _sleep: float = 1.0

func _ready() -> void:
	# TODO : récupérer les valeurs depuis le personnage (valeurs en dur pour le test)
	set_stats(65, 40, 80, 25)
	set_multipliers(1.2, 0.8, 1.5)

# Les valeurs vont de 0 à max_value de la ProgressBar (100 par défaut)
func set_stats(science: float, litterature: float, social_life: float, hobby: float) -> void:
	# on oublie les animations en cours, les nouvelles valeurs les remplacent
	for tween in _bar_tweens.values():
		tween.kill()
	_bar_tweens.clear()
	_bar_targets.clear()

	_science_progress_bar.value = science
	_literature_progress_bar.value = litterature
	_social_life_progress_bar.value = social_life
	_hobby_progress_bar.value = hobby

	_science_percent_label.text = "%d" % (science / _science_progress_bar.max_value * 100)
	_literature_percent_label.text = "%d" % (litterature / _literature_progress_bar.max_value * 100)
	_social_life_percent_label.text = "%d" % (social_life / _social_life_progress_bar.max_value * 100)
	_hobby_percent_label.text = "%d" % (hobby / _hobby_progress_bar.max_value * 100)

# Ajoute amount à la jauge de la stat (une valeur négative la fait baisser)
func add_stat(type: StatType.Type, amount: float) -> void:
	var bar: ProgressBar
	var amount_label: Label
	match type:
		StatType.Type.SCIENTIFIC:
			bar = _science_progress_bar
			amount_label = _science_percent_label
		StatType.Type.LITERATURE:
			bar = _literature_progress_bar
			amount_label = _literature_percent_label
		StatType.Type.SOCIAL_LIFE:
			bar = _social_life_progress_bar
			amount_label = _social_life_percent_label
		StatType.Type.LEISURE:
			bar = _hobby_progress_bar
			amount_label = _hobby_percent_label
		_:
			# les autres stats sont des multiplicateurs, elles n'ont pas de jauge
			return

	var start: float = _bar_targets.get(bar, bar.value)
	var target: float = clampf(start + amount, bar.min_value, bar.max_value)
	_bar_targets[bar] = target

	if _bar_tweens.has(bar):
		_bar_tweens[bar].kill()
	var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "value", target, _bar_animation_duration)
	# le pourcentage défile en même temps que la jauge : le tween appelle cette fonction anonyme à chaque frame
	var update_label: Callable = func(value: float) -> void:
		amount_label.text = "%d" % (value / bar.max_value * 100)
	tween.tween_method(update_label, bar.value, target, _bar_animation_duration)
	_bar_tweens[bar] = tween

func set_multipliers(methodology: float, attendance: float, sleep: float) -> void:
	_methodology = clampf(methodology, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_attendance = clampf(attendance, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_sleep = clampf(sleep, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_update_multiplier_labels()

# Ajoute amount au multiplicateur de la stat (une valeur négative le fait baisser)
func add_multiplier(type: StatType.Type, amount: float) -> void:
	match type:
		# clampf bloque la valeur dans l'intervalle, comme le fait la ProgressBar pour les jauges
		StatType.Type.METHODOLOGY:
			_methodology = clampf(_methodology + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
		StatType.Type.ATTENDANCE:
			_attendance = clampf(_attendance + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
		StatType.Type.SLEEP:
			_sleep = clampf(_sleep + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
		_:
			# les autres stats ont une jauge, pas de multiplicateur
			return
	_update_multiplier_labels()

func _update_multiplier_labels() -> void:
	_methodology_value_label.text = _format_multiplier(_methodology)
	_attendance_value_label.text = _format_multiplier(_attendance)
	_sleep_value_label.text = _format_multiplier(_sleep)

# ex : 1.2 -> "x1,20" (%.2f écrit un point, on le remplace par une virgule pour l'affichage en français)
func _format_multiplier(value: float) -> String:
	return ("x%.2f" % value).replace(".", ",")
