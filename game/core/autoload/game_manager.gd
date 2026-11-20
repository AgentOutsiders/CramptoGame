# Autoload that keeps the player choices between the scenes
extends Node

# The two game modes: STORY has an end, INFINITE never ends
enum GameMode { STORY, INFINITE }

# Mode chosen in the mode select screen
var selected_mode: GameMode = GameMode.STORY

# Character chosen in the character select screen
var selected_character: CharacterData = null

const WEEKS_PER_YEAR: int = 52
const RENT_FREQUENCY_WEEKS: int = 4
const RENT_AMOUNT: int = 500
const DEPRESSION_THRESHOLD: float = 20.0
const SCHOOL_PASS_THRESHOLD: float = 50.0
const INFINITE_SCHOOL_THRESHOLD_INCREASE_FACTOR: float = 1.15
const STARTING_MONEY: int = 1000
const SHOP_ITEMS_PER_WEEK: int = 6

# Alternate names kept explicit for balancing and testability.
const YEAR_DURATION_WEEKS: int = WEEKS_PER_YEAR
const RENT_FREQUENCY: int = RENT_FREQUENCY_WEEKS
const SCHOOL_THRESHOLD: float = SCHOOL_PASS_THRESHOLD
const INFINITE_THRESHOLD_INCREASE_FACTOR: float = INFINITE_SCHOOL_THRESHOLD_INCREASE_FACTOR

const EVENT_SCENE_PATH: String = "res://ui/event/event.tscn"
const WEEKEND_SCENE_PATH: String = "res://ui/weekend/weekend.tscn"
const END_SCENE_PATH: String = "res://ui/end/end_game.tscn"
const MAIN_MENU_PATH: String = "res://ui/main/main_menu.tscn"

const DEFEAT_RENT: String = "loyer"
const DEFEAT_DEPRESSION: String = "depression"
const DEFEAT_SCHOOL: String = "echec_scolaire"

var current_week: int = 1
var current_year: int = 1
var money: int = STARTING_MONEY
var inventory: Dictionary = {}
var events_remaining_this_week: int = 0
var current_shop_items: Array[Item] = []
var stats: Dictionary = {}
var current_school_threshold: float = SCHOOL_PASS_THRESHOLD
var is_game_over: bool = false
var has_won: bool = false
var end_reason: String = ""

signal stats_updated()
signal money_updated(current_money: int)


func start_new_run(character: CharacterData, mode: int = -1) -> void:
	selected_character = character
	if mode >= 0:
		selected_mode = mode as GameMode
	current_week = 1
	current_year = 1
	money = STARTING_MONEY
	inventory.clear()
	events_remaining_this_week = 0
	current_shop_items.clear()
	current_school_threshold = SCHOOL_PASS_THRESHOLD
	is_game_over = false
	has_won = false
	end_reason = ""

	stats.clear()
	if character != null:
		stats[StatType.Type.SCIENTIFIC] = float(character.scientific)
		stats[StatType.Type.LITERATURE] = float(character.literature)
		stats[StatType.Type.METHODOLOGY] = clampf(character.methodology, 0.5, 2.0)
		stats[StatType.Type.ATTENDANCE] = clampf(character.attendance, 0.5, 2.0)
		stats[StatType.Type.SLEEP] = clampf(character.sleep, 0.5, 2.0)
		stats[StatType.Type.SOCIAL_LIFE] = float(character.social_life)
		stats[StatType.Type.LEISURE] = float(character.hobby)

	if not check_depression():
		return

	renew_shop_items()
	start_week_events()
	stats_updated.emit()
	money_updated.emit(money)
	get_tree().change_scene_to_file(EVENT_SCENE_PATH)


func apply_stat_modifier(modifier: StatModifier) -> void:
	if is_game_over or modifier == null:
		return

	var stat_type: StatType.Type = modifier.get_stat_type()
	if StatType.is_multiplier(stat_type):
		var current_multiplier: float = float(stats.get(stat_type, 1.0))
		stats[stat_type] = clampf(
			current_multiplier + modifier.get_multiplier_bonus(),
			0.5,
			2.0
		)
	else:
		var current_value: float = float(stats.get(stat_type, 0.0))
		stats[stat_type] = clampf(current_value + modifier.get_flat_bonus(), 0.0, 100.0)

	stats_updated.emit()
	check_depression()


func apply_money_change(amount: int) -> void:
	money += amount
	money_updated.emit(money)


func advance_after_event() -> void:
	events_remaining_this_week -= 1
	if events_remaining_this_week > 0:
		get_tree().change_scene_to_file(EVENT_SCENE_PATH)
	else:
		get_tree().change_scene_to_file(WEEKEND_SCENE_PATH)


func start_next_week() -> void:
	if is_game_over:
		return

	if not pay_rent():
		return

	if current_week >= WEEKS_PER_YEAR:
		if not validate_current_year():
			return

		if selected_mode == GameMode.STORY:
			end_run(true)
			return

		current_year += 1
		current_school_threshold = clampf(
			current_school_threshold * INFINITE_SCHOOL_THRESHOLD_INCREASE_FACTOR,
			SCHOOL_PASS_THRESHOLD,
			100.0
		)
		current_week = 1
	else:
		current_week += 1

	renew_shop_items()
	start_week_events()
	get_tree().change_scene_to_file(EVENT_SCENE_PATH)


func start_week_events() -> void:
	events_remaining_this_week = randi_range(1, 2)


func renew_shop_items() -> void:
	current_shop_items.clear()
	var available_items: Array[Item] = []
	var item_directory: DirAccess = DirAccess.open("res://data/item")
	if item_directory != null:
		item_directory.list_dir_begin()
		var file_name: String = item_directory.get_next()
		while file_name != "":
			if not item_directory.current_is_dir() and file_name.ends_with(".tres"):
				var item_resource: Resource = load("res://data/item/" + file_name)
				if item_resource is Item:
					available_items.append(item_resource)
			file_name = item_directory.get_next()
		item_directory.list_dir_end()

	available_items.shuffle()
	var item_count: int = min(SHOP_ITEMS_PER_WEEK, available_items.size())
	for index in range(item_count):
		current_shop_items.append(available_items[index])


func pay_rent() -> bool:
	if current_week % RENT_FREQUENCY_WEEKS != 0:
		return true
	if money < RENT_AMOUNT:
		end_run(false, DEFEAT_RENT)
		return false
	money -= RENT_AMOUNT
	money_updated.emit(money)
	return true


func validate_current_year() -> bool:
	if get_academic_score() < current_school_threshold:
		end_run(false, DEFEAT_SCHOOL)
		return false
	return true


func check_depression() -> bool:
	if get_well_being_score() < DEPRESSION_THRESHOLD:
		end_run(false, DEFEAT_DEPRESSION)
		return false
	return true


func get_academic_score() -> float:
	var academic_base: float = (
		float(stats.get(StatType.Type.SCIENTIFIC, 0.0))
		+ float(stats.get(StatType.Type.LITERATURE, 0.0))
	) * 0.5
	var academic_multipliers: float = (
		float(stats.get(StatType.Type.METHODOLOGY, 1.0))
		+ float(stats.get(StatType.Type.ATTENDANCE, 1.0))
	) * 0.5
	return clampf(academic_base * academic_multipliers, 0.0, 100.0)


func get_well_being_score() -> float:
	var well_being_base: float = (
		float(stats.get(StatType.Type.SOCIAL_LIFE, 0.0))
		+ float(stats.get(StatType.Type.LEISURE, 0.0))
	) * 0.5
	var sleep_multiplier: float = float(stats.get(StatType.Type.SLEEP, 1.0))
	return clampf(well_being_base * sleep_multiplier, 0.0, 100.0)


func buy_item(item: Item, quantity: int) -> bool:
	if item == null or quantity <= 0:
		return false
	var total_price: int = quantity * int(item.get_price())
	if money < total_price:
		return false
	var currently_owned: int = int(inventory.get(item, 0))
	var quantity_to_add: int = min(quantity, item.get_max_owned() - currently_owned)
	if quantity_to_add <= 0:
		return false

	money -= quantity_to_add * int(item.get_price())
	inventory[item] = currently_owned + quantity_to_add
	for modifier in item.get_stat_modifiers():
		for copy_index in range(quantity_to_add):
			apply_stat_modifier(modifier)
	money_updated.emit(money)
	return true


func sell_item(item: Item, quantity: int) -> bool:
	if item == null or quantity <= 0:
		return false
	var currently_owned: int = int(inventory.get(item, 0))
	var quantity_to_sell: int = min(quantity, currently_owned)
	if quantity_to_sell <= 0:
		return false

	money += quantity_to_sell * int(item.get_sell_price())
	inventory[item] = currently_owned - quantity_to_sell
	if inventory[item] <= 0:
		inventory.erase(item)
	for modifier in item.get_stat_modifiers():
		var reversed_modifier: StatModifier = StatModifier.new()
		reversed_modifier._stat_type = modifier.get_stat_type()
		reversed_modifier._flat_bonus = -modifier.get_flat_bonus() * quantity_to_sell
		reversed_modifier._multiplier_bonus = -modifier.get_multiplier_bonus() * quantity_to_sell
		apply_stat_modifier(reversed_modifier)
	money_updated.emit(money)
	return true


func end_run(did_win: bool, reason: String = "") -> void:
	is_game_over = true
	has_won = did_win
	end_reason = reason
	get_tree().change_scene_to_file(END_SCENE_PATH)
