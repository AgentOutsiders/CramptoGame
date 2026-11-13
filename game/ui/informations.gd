extends VBoxContainer
class_name Informations

# gauges go from 0 to 100, multipliers from MIN_MULTIPLIER to MAX_MULTIPLIER
const MIN_MULTIPLIER: float = 0.5
const MAX_MULTIPLIER: float = 2.0
# duration of one way (or the way back) of the preview blinking
const PREVIEW_BLINK_DURATION: float = 0.5
# color of the part of a gauge that will be lost (sale preview)
const PREVIEW_LOSS_COLOR: Color = Color(0.9, 0.2, 0.2)

@export var _bar_animation_duration: float = 0.4
# Minimum width of the value labels (0 = no minimum).
# In the popups, it is set in the inspector so that "100 → 100" fits:
# the panel then keeps the same size during the preview.
@export var _percent_label_min_width: float = 0
@export var _multiplier_label_min_width: float = 0

# gauge of each stat
@onready var _bars: Dictionary = {
	StatType.Type.SCIENTIFIC: $StatsVBox/StatsGrid/ScienceProgressBar,
	StatType.Type.LITERATURE: $StatsVBox/StatsGrid/LiteratureProgressBar,
	StatType.Type.SOCIAL_LIFE: $StatsVBox/StatsGrid/SocialLifeProgressBar,
	StatType.Type.LEISURE: $StatsVBox/StatsGrid/HobbyProgressBar,
}
# label that shows the value of each stat (gauges and multipliers)
@onready var _labels: Dictionary = {
	StatType.Type.SCIENTIFIC: $StatsVBox/StatsGrid/SciencePercentLabel,
	StatType.Type.LITERATURE: $StatsVBox/StatsGrid/LiteraturePercentLabel,
	StatType.Type.SOCIAL_LIFE: $StatsVBox/StatsGrid/SocialLifePercentLabel,
	StatType.Type.LEISURE: $StatsVBox/StatsGrid/HobbyPercentLabel,
	StatType.Type.METHODOLOGY: $MultipliersVBox/MultipliersGrid/MethodologyValueLabel,
	StatType.Type.ATTENDANCE: $MultipliersVBox/MultipliersGrid/AttendanceValueLabel,
	StatType.Type.SLEEP: $MultipliersVBox/MultipliersGrid/SleepValueLabel,
}

# value of each stat: StatType.Type -> float
var _values: Dictionary = {}
# animations and background gauges created for the preview, removed when it is cleared
var _preview_tweens: Array[Tween] = []
var _preview_bars: Array[ProgressBar] = []

func _ready() -> void:
	for type in _labels:
		if StatType.is_multiplier(type):
			_labels[type].custom_minimum_size.x = _multiplier_label_min_width
		else:
			_labels[type].custom_minimum_size.x = _percent_label_min_width
	# test values, replaced by the player's values with set_values() (see Shop.setup())
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

# replaces the values of the given stats: StatType.Type -> value
func set_values(values: Dictionary) -> void:
	for type in values:
		_values[type] = values[type]
	_update_bars()
	_update_multipliers()

# current value of a stat (gauge or multiplier)
func get_stat(type: StatType.Type) -> float:
	return _values[type]

# Adds amount to the stat's gauge (a negative value lowers it), with an animation
func add_stat(type: StatType.Type, amount: float) -> void:
	if not _bars.has(type):
		# the other stats are multipliers, they have no gauge
		return
	_values[type] = clampf(_values[type] + amount, 0, 100)
	_labels[type].text = "%d" % _values[type]
	var tween: Tween = create_tween()
	tween.tween_property(_bars[type], "value", _values[type], _bar_animation_duration)

# Adds amount to the stat's multiplier (a negative value lowers it)
func add_multiplier(type: StatType.Type, amount: float) -> void:
	if not StatType.is_multiplier(type):
		# the other stats have a gauge, not a multiplier
		return
	_values[type] = clampf(_values[type] + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
	_update_multipliers()

# copies all the values of another panel (e.g. the shop's one into a popup's one)
func copy_from(other: Informations) -> void:
	for type in _values:
		_values[type] = other.get_stat(type)
	clear_preview()

# Shows what count copies of the item would change, without really changing anything.
# count is negative for a sale.
func show_preview(modifiers: Array[StatModifier], count: int) -> void:
	clear_preview()
	for modifier in modifiers:
		var type: StatType.Type = modifier.get_stat_type()
		if StatType.is_multiplier(type):
			_preview_multiplier(type, modifier.get_multiplier_bonus() * count)
		else:
			_preview_bar(type, modifier.get_flat_bonus() * count)

# stops the preview and shows the real values again
func clear_preview() -> void:
	for tween in _preview_tweens:
		tween.kill()
	_preview_tweens.clear()
	for preview_bar in _preview_bars:
		preview_bar.queue_free()
	_preview_bars.clear()
	_update_bars()
	_update_multipliers()

# Gauge preview: the gauge shows the smaller of the two values, and a 2nd gauge
# drawn behind it shows the bigger one. Only the difference sticks out, and it blinks.
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
	# show_behind_parent: the 2nd gauge is drawn behind the real one, not on top of it
	preview_bar.show_behind_parent = true
	# no background, otherwise it would hide the real gauge
	preview_bar.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	# same fill as the real gauge (copied with duplicate), red if it is a loss
	var fill: StyleBoxFlat = bar.get_theme_stylebox("fill").duplicate()
	if target < current:
		fill.bg_color = PREVIEW_LOSS_COLOR
	preview_bar.add_theme_stylebox_override("fill", fill)
	bar.add_child(preview_bar)
	# the 2nd gauge takes exactly the size of the real one
	preview_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_preview_bars.append(preview_bar)

	# modulate:a = opacity of the 2nd gauge, it goes from 1 to 0.2 then back to 1, in a loop
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(preview_bar, "modulate:a", 0.2, PREVIEW_BLINK_DURATION)
	tween.tween_property(preview_bar, "modulate:a", 1.0, PREVIEW_BLINK_DURATION)
	_preview_tweens.append(tween)

# Multiplier preview: the label shows "before → after" and blinks
func _preview_multiplier(type: StatType.Type, amount: float) -> void:
	var current: float = _values[type]
	var target: float = clampf(current + amount, MIN_MULTIPLIER, MAX_MULTIPLIER)
	if target == current:
		return
	_labels[type].text = "%s → %s" % [_format_multiplier(current), _format_multiplier(target)]

	# modulate:a = opacity of the label, it goes from 1 to 0.2 then back to 1, in a loop
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(_labels[type], "modulate:a", 0.2, PREVIEW_BLINK_DURATION)
	tween.tween_property(_labels[type], "modulate:a", 1.0, PREVIEW_BLINK_DURATION)
	_preview_tweens.append(tween)

# shows the value of each gauge, without animation
func _update_bars() -> void:
	for type in _bars:
		_bars[type].value = _values[type]
		_labels[type].text = "%d" % _values[type]

# shows the value of each multiplier
func _update_multipliers() -> void:
	for type in [StatType.Type.METHODOLOGY, StatType.Type.ATTENDANCE, StatType.Type.SLEEP]:
		_labels[type].text = _format_multiplier(_values[type])
		_labels[type].modulate.a = 1.0

# e.g. 1.2 -> "x1,20" (%.2f writes a dot, replaced by a comma for the French display)
func _format_multiplier(value: float) -> String:
	return ("x%.2f" % value).replace(".", ",")
