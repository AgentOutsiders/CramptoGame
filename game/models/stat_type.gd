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

# nom de la stat tel qu'il est affiché au joueur
# static : appelable directement depuis la classe, sans créer d'instance (StatType.display_name(...))
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

# les multiplicateurs utilisent _multiplier_bonus, les autres stats (jauges) utilisent _flat_bonus
static func is_multiplier(type: Type) -> bool:
	return type in [Type.METHODOLOGY, Type.ATTENDANCE, Type.SLEEP]
