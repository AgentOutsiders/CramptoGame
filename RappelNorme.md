# La Casse (Majuscules et Minuscules)
Fichiers et Dossiers (snake_case) : Toujours en minuscules séparés par des tirets du bas. Exemple : student_profile.gd, main_menu.tscn.

Classes et Nœuds (PascalCase) : Chaque mot prend une majuscule, sans espaces. Exemple : GameManager, EventCard.

Variables (snake_case) : Minuscules et tirets du bas. Exemple : current_money, academic_score.

Fonctions (snake_case) : Même chose que les variables, généralement en commençant par un verbe d'action. Exemple : apply_card_effect(), end_week().

Constantes (SCREAMING_SNAKE_CASE) : Tout en majuscules avec des tirets du bas. Exemple : MAX_STRESS = 100, STARTING_MONEY = 500.

Énumérations : Le nom de l'énumération en PascalCase, et ses valeurs en SCREAMING_SNAKE_CASE. Exemple : enum Subject { SCIENCE, LITERATURE, METHODOLOGY }.

# Sémantique et Astuces spécifiques
Variables et méthodes "Privées" (_snake_case) : Si un élément ne doit être manipulé qu'à l'intérieur de son propre script (et non par un autre script), préfixez-le d'un tiret du bas. Exemple : _calculate_weekly_balance(). Note : C'est pour cela que les fonctions natives de Godot s'écrivent _ready() ou _process().

Les Booléens (Poser une question) : Préfixez vos variables vrai/faux par is_, has_ ou can_ pour que leur intention soit limpide. Exemple : is_bankrupt, has_transport_pass.

Les Signaux (Verbe au passé) : Nommez-les en snake_case pour décrire un événement qui vient de se produire. Exemple : card_swiped, week_ended, stats_updated.

Des noms explicites : Évitez les abréviations mystérieuses. Dans le contexte de votre jeu, préférez well_being_score à wbs, ou emotional_stability à emo_stab.
