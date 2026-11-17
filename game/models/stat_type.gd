class_name StatType

enum Type {
	SCIENTIFIC,
	LITERATURE,
	METHODOLOGY,
	ATTENDANCE,
	SLEEP,
	SOCIAL_LIFE,
	LEISURE
}

# name of the stat as shown to the player
# static: can be called directly on the class, without creating an instance (StatType.display_name(...))
static func display_name(type: Type) -> String:
	match type:
		Type.SCIENTIFIC:
			return "Science"
		Type.LITERATURE:
			return "Littérature"
		Type.METHODOLOGY:
			return "Méthodologie"
		Type.ATTENDANCE:
			return "Assiduité"
		Type.SLEEP:
			return "Sommeil"
		Type.SOCIAL_LIFE:
			return "Vie sociale"
		Type.LEISURE:
			return "Loisirs"
	return ""

# multipliers use _multiplier_bonus, the other stats (gauges) use _flat_bonus
static func is_multiplier(type: Type) -> bool:
	return type in [Type.METHODOLOGY, Type.ATTENDANCE, Type.SLEEP]
