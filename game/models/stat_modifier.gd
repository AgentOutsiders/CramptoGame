extends Resource
class_name StatModifier

@export var _stat_type: StatType.Type
@export var _flat_bonus: int = 0
@export var _multiplier_bonus: float = 0.0

# texte affiché dans les popups, ex : "Scientifique : +10" ou "Sommeil : +0,80"
func display_text() -> String:
	var stat_name: String = StatType.display_name(_stat_type)
	if StatType.is_multiplier(_stat_type):
		# %.2f écrit un point, on le remplace par une virgule pour l'affichage en français
		return "%s : %s" % [stat_name, ("%+.2f" % _multiplier_bonus).replace(".", ",")]
	return "%s : %+d" % [stat_name, _flat_bonus]
