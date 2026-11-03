extends Control

const MODE_SELECT_PATH: String = "res://ui/main/mode_select.tscn"
const FONT: Font = preload("res://assets/font/PixelOperator8.ttf")

const STAT_MAX: int = 100
const MULTIPLIER_MIN: float = 0.5
const MULTIPLIER_MAX: float = 2.0
const BAR_ANIMATION_TIME: float = 0.25
const PREVIEW_FADE_TIME: float = 0.15
const IDLE_FRAME_TIME: float = 0.5
const BLINK_TIME: float = 0.15
const BLINK_DELAY_MIN: float = 2.0
const BLINK_DELAY_MAX: float = 5.0

const STATS: Array = [
	{"property": "scientific", "label": "Scientifique", "color": Color("ff4136"), "multiplier": false},
	{"property": "literature", "label": "Littérature", "color": Color("ff851b"), "multiplier": false},
	{"property": "methodology", "label": "Méthodologie", "color": Color("0074d9"), "multiplier": true},
	{"property": "attendance", "label": "Assiduité", "color": Color("2ecc40"), "multiplier": true},
	{"property": "sleep", "label": "Sommeil", "color": Color("b10dc9"), "multiplier": false},
	{"property": "social_life", "label": "Vie sociale", "color": Color("ffdc00"), "multiplier": false},
	{"property": "hobby", "label": "Hobby", "color": Color("39cccc"), "multiplier": false},
]

const THUMBNAIL_SIZE: Vector2 = Vector2(168, 168)
const THUMBNAIL_ZOOM: int = 3
const PREVIEW_ZOOM: int = 6
const THUMBNAIL_COUNT: int = 3
const SELECTED_PAPER_COLOR: Color = Color(0.82, 0.82, 0.82)
const HOVERED_PAPER_COLOR: Color = Color(0.92, 0.92, 0.9)
const INK: Color = Color(0.11, 0.14, 0.3)
const BAR_BACKGROUND_COLOR: Color = Color(0.86, 0.84, 0.79)
const BAR_BORDER_COLOR: Color = Color(0.78, 0.75, 0.69)

@onready var character_preview: TextureRect = %CharacterPreview
@onready var tape: TextureRect = %Tape
@onready var character_name_label: Label = %CharacterNameLabel
@onready var character_description: Label = %CharacterDescription
@onready var stats_grid: GridContainer = %StatsGrid
@onready var thumbnail_row: HBoxContainer = %ThumbnailRow
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton

var characters: Array[CharacterData] = []
var selected_character: CharacterData = null

var stat_bars: Dictionary = {}
var stat_value_labels: Dictionary = {}
var thumbnails: Array[Button] = []

var bars_tween: Tween = null
var preview_tween: Tween = null

var idle_frames: Array[AtlasTexture] = []
var idle_time: float = 0.0
var next_blink: float = 0.0


func _ready() -> void:
	load_characters()
	build_stat_rows()
	build_thumbnails()

	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)
	confirm_button.mouse_entered.connect(confirm_button.grab_focus)
	confirm_button.mouse_exited.connect(confirm_button.release_focus)

	Highlighter.apply(self)
	tape.texture = Highlighter.get_image("tape.png")

	if characters.size() > 0:
		select_character(0)


func _process(delta: float) -> void:
	if idle_frames.size() == 0:
		return

	idle_time = idle_time + delta

	var pose_count: int = int(idle_frames.size() / 2.0)
	var frame: int = int(idle_time / IDLE_FRAME_TIME) % pose_count

	if idle_time >= next_blink:
		frame = frame + pose_count
		if idle_time >= next_blink + BLINK_TIME:
			next_blink = idle_time + randf_range(BLINK_DELAY_MIN, BLINK_DELAY_MAX)

	character_preview.texture = idle_frames[frame]


func load_characters() -> void:
	characters.append(load("res://core/data/character1.tres"))
	characters.append(load("res://core/data/character2.tres"))
	characters.append(load("res://core/data/character3.tres"))
	characters.append(load("res://core/data/character4.tres"))


func build_stat_rows() -> void:
	for stat in STATS:
		var name_label: Label = create_label(stat["label"], 30)
		stats_grid.add_child(name_label)

		var bar: ProgressBar = ProgressBar.new()
		bar.custom_minimum_size = Vector2(400, 28)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.show_percentage = false
		if stat["multiplier"]:
			bar.min_value = MULTIPLIER_MIN
			bar.max_value = MULTIPLIER_MAX
			bar.step = 0.01
		else:
			bar.max_value = STAT_MAX
		bar.add_theme_stylebox_override("background", create_box(BAR_BACKGROUND_COLOR))
		bar.add_theme_stylebox_override("fill", create_box(stat["color"]))
		stats_grid.add_child(bar)

		var value_label: Label = create_label("0", 30)
		value_label.custom_minimum_size.x = 140
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_grid.add_child(value_label)

		stat_bars[stat["property"]] = bar
		stat_value_labels[stat["property"]] = value_label


func build_thumbnails() -> void:
	var group: ButtonGroup = ButtonGroup.new()

	for i in range(characters.size()):
		var character: CharacterData = characters[i]

		var button: Button = Button.new()
		button.toggle_mode = true
		button.button_group = group
		button.icon = scale_texture(character.portrait, THUMBNAIL_ZOOM)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.custom_minimum_size = THUMBNAIL_SIZE
		button.tooltip_text = character.character_name
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var paper_number: int = i % THUMBNAIL_COUNT + 1
		var paper_path: String = "res://assets/ui/menu/thumb_" + str(paper_number) + ".png"
		var selected_path: String = "res://assets/ui/menu/thumb_selected_" + str(paper_number) + ".png"

		var paper: StyleBoxTexture = create_paper_box(paper_path)
		var hovered: StyleBoxTexture = create_paper_box(paper_path)
		hovered.modulate_color = HOVERED_PAPER_COLOR
		var selected: StyleBoxTexture = create_paper_box(selected_path)
		selected.modulate_color = SELECTED_PAPER_COLOR

		button.add_theme_stylebox_override("normal", paper)
		button.add_theme_stylebox_override("hover", hovered)
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover_pressed", selected)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		button.pressed.connect(_on_thumbnail_pressed.bind(i))
		thumbnail_row.add_child(button)
		thumbnails.append(button)


func select_character(index: int) -> void:
	var character: CharacterData = characters[index]
	if character == selected_character:
		return

	selected_character = character
	thumbnails[index].button_pressed = true

	set_idle_frames(character.idle_sheet)
	character_name_label.text = character.character_name
	character_description.text = character.description
	animate_preview()
	animate_stats(character)


func animate_stats(character: CharacterData) -> void:
	if bars_tween != null:
		bars_tween.kill()

	bars_tween = create_tween()
	bars_tween.set_parallel(true)
	bars_tween.set_trans(Tween.TRANS_QUAD)
	bars_tween.set_ease(Tween.EASE_OUT)

	for stat in STATS:
		var property: String = stat["property"]
		var value: float = character.get(property)
		stat_value_labels[property].text = format_stat(value, stat["multiplier"])
		bars_tween.tween_property(stat_bars[property], "value", value, BAR_ANIMATION_TIME)


func animate_preview() -> void:
	if preview_tween != null:
		preview_tween.kill()

	character_preview.self_modulate.a = 0.0
	preview_tween = create_tween()
	preview_tween.tween_property(character_preview, "self_modulate:a", 1.0, PREVIEW_FADE_TIME)


func set_idle_frames(sheet: Texture2D) -> void:
	idle_frames.clear()

	var big_sheet: ImageTexture = scale_texture(sheet, PREVIEW_ZOOM)
	var frame_size: int = big_sheet.get_height()
	var frame_count: int = int(big_sheet.get_width() / float(frame_size))

	for i in range(frame_count):
		var frame: AtlasTexture = AtlasTexture.new()
		frame.atlas = big_sheet
		frame.region = Rect2(i * frame_size, 0, frame_size, frame_size)
		idle_frames.append(frame)

	idle_time = 0.0
	next_blink = randf_range(BLINK_DELAY_MIN, BLINK_DELAY_MAX)
	character_preview.texture = idle_frames[0]


func scale_texture(texture: Texture2D, factor: int) -> ImageTexture:
	var image: Image = texture.get_image()
	image.resize(image.get_width() * factor, image.get_height() * factor, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


func format_stat(value: float, is_multiplier: bool) -> String:
	if is_multiplier:
		var text: String = "%.2f" % value
		text = text.replace(".", ",")
		return "×" + text
	else:
		return str(int(value))


func create_label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	return label


func create_box(color: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = BAR_BORDER_COLOR
	box.set_border_width_all(2)
	return box


func create_paper_box(texture_path: String) -> StyleBoxTexture:
	var box: StyleBoxTexture = StyleBoxTexture.new()
	box.texture = load(texture_path)
	box.content_margin_left = 16
	box.content_margin_top = 16
	box.content_margin_right = 24
	box.content_margin_bottom = 24
	return box


func _on_thumbnail_pressed(index: int) -> void:
	AudioManager.play_click()
	select_character(index)


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MODE_SELECT_PATH)


func _on_confirm_pressed() -> void:
	AudioManager.play_click()
	GameManager.selected_character = selected_character
