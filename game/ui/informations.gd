extends VBoxContainer
class_name Informations

const MIN_MULTIPLIER: float = 0.5
const MAX_MULTIPLIER: float = 2.0

@onready var _science_bar: ProgressBar = $Stats/GridContainer/ScienceProgressBar
@onready var _litterature_bar: ProgressBar = $Stats/GridContainer/LitteratureProgressBar
@onready var _social_life_bar: ProgressBar = $Stats/GridContainer/SocialLifeProgressBar
@onready var _hobby_bar: ProgressBar = $Stats/GridContainer/HobbyProgressBar

@onready var _methodology_value_label: Label = $Multipliers/GridContainer/MethodologyValueLabel
@onready var _attendance_value_label: Label = $Multipliers/GridContainer/AttendanceValueLabel
@onready var _sleep_value_label: Label = $Multipliers/GridContainer/SleepValueLabel


func _ready() -> void:
	# TODO : récupérer les valeurs depuis le personnage (valeurs en dur pour le test)
	set_stats(65, 40, 80, 25)
	set_multipliers(1.2, 0.8, 1.5)

# Les valeurs vont de 0 à max_value de la ProgressBar (100 par défaut)
func set_stats(science: float, litterature: float, social_life: float, hobby: float) -> void:
	_science_bar.value = science
	_litterature_bar.value = litterature
	_social_life_bar.value = social_life
	_hobby_bar.value = hobby

func set_multipliers(methodology: float, attendance: float, sleep: float) -> void:
	_methodology_value_label.text = "x%.2f" % methodology
	_attendance_value_label.text = "x%.2f" % attendance
	_sleep_value_label.text = "x%.2f" % sleep
