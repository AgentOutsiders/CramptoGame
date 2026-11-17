extends Resource
class_name StatModifier

@export var _stat_type: StatType.Type
@export var _flat_bonus: int = 0
@export var _multiplier_bonus: float = 0.0

func get_stat_type() -> StatType.Type:
	return _stat_type

func get_flat_bonus() -> int:
	return _flat_bonus

func get_multiplier_bonus() -> float:
	return _multiplier_bonus

# text shown in the popups, e.g. "Science : +10" or "Sommeil : +0,80"
func display_text() -> String:
	var stat_name: String = StatType.display_name(_stat_type)
	if StatType.is_multiplier(_stat_type):
		# %.2f writes a dot, replaced by a comma for the French display
		return "%s : %s" % [stat_name, ("%+.2f" % _multiplier_bonus).replace(".", ",")]
	return "%s : %+d" % [stat_name, _flat_bonus]
