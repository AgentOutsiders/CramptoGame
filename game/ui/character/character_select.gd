# Character select screen: thumbnails at the bottom, big animated preview,
# name, description and stat bars of the selected character
extends Control

# Path of the previous screen and font used for the texts
const MODE_SELECT_PATH: String = "res://ui/main/mode_select.tscn"
const FONT: Font = preload("res://assets/font/PixelOperator8.ttf")

# Limits of the stat bars
const STAT_MAX: int = 100
const MULTIPLIER_MIN: float = 0.5
const MULTIPLIER_MAX: float = 2.0

# Times of the animations in seconds
const BAR_ANIMATION_TIME: float = 0.25
const PREVIEW_FADE_TIME: float = 0.15
const IDLE_FRAME_TIME: float = 0.5
const BLINK_TIME: float = 0.15
const BLINK_DELAY_MIN: float = 2.0
const BLINK_DELAY_MAX: float = 5.0

# List of the stats to show: variable name in CharacterData, text, bar color and if it is a multiplier (0.5 to 2) or a normal stat (0 to 100)
const STATS: Array = [
	{"property": "scientific", "label": "Scientifique", "color": Color("ff4136"), "multiplier": false},
	{"property": "literature", "label": "Littérature", "color": Color("ff851b"), "multiplier": false},
	{"property": "methodology", "label": "Méthodologie", "color": Color("0074d9"), "multiplier": true},
	{"property": "attendance", "label": "Assiduité", "color": Color("2ecc40"), "multiplier": true},
	{"property": "sleep", "label": "Sommeil", "color": Color("b10dc9"), "multiplier": false},
	{"property": "social_life", "label": "Vie sociale", "color": Color("ffdc00"), "multiplier": false},
	{"property": "hobby", "label": "Hobby", "color": Color("39cccc"), "multiplier": false},
]

# Size and look of the thumbnails and the preview
const THUMBNAIL_SIZE: Vector2 = Vector2(168, 168)
const THUMBNAIL_ZOOM: int = 3
const PREVIEW_ZOOM: int = 6

# Number of different paper images for the thumbnails
const THUMBNAIL_COUNT: int = 3

# Colors of the thumbnail paper when selected and when hovered
const SELECTED_PAPER_COLOR: Color = Color(0.82, 0.82, 0.82)
const HOVERED_PAPER_COLOR: Color = Color(0.92, 0.92, 0.9)

# Dark blue color of the text, like a pen
const INK: Color = Color(0.11, 0.14, 0.3)

# Colors of the empty part and of the border of the stat bars
const BAR_BACKGROUND_COLOR: Color = Color(0.86, 0.84, 0.79)
const BAR_BORDER_COLOR: Color = Color(0.78, 0.75, 0.69)

# Nodes of the scene, found with their unique name thanks to the % sign
@onready var character_preview: TextureRect = %CharacterPreview
@onready var tape: TextureRect = %Tape
@onready var character_name_label: Label = %CharacterNameLabel
@onready var character_description: Label = %CharacterDescription
@onready var stats_grid: GridContainer = %StatsGrid
@onready var thumbnail_row: HBoxContainer = %ThumbnailRow
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton

# All the characters and the one selected right now
var characters: Array[CharacterData] = []
var selected_character: CharacterData = null

# Bars and value labels of each stat, found with the stat name
var stat_bars: Dictionary = {}
var stat_value_labels: Dictionary = {}

# Thumbnail buttons, in the same order as the characters
var thumbnails: Array[Button] = []

# Current animations, kept so we can stop them if a new one starts
var bars_tween: Tween = null
var preview_tween: Tween = null

# Frames of the idle animation and timers for the animation and the blink
var idle_frames: Array[AtlasTexture] = []
var idle_time: float = 0.0
var next_blink: float = 0.0


# Called when the scene is loaded
func _ready() -> void:
	load_characters()
	build_stat_rows()
	build_thumbnails()

	# When a button is pressed, we call its function written below
	back_button.pressed.connect(_on_back_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	# When the mouse goes on a button it gets highlighted, and when it leaves it is not anymore
	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)
	confirm_button.mouse_entered.connect(confirm_button.grab_focus)
	confirm_button.mouse_exited.connect(confirm_button.release_focus)

	# We put the chosen highlighter color on the screen and on the tape
	Highlighter.apply(self)
	tape.texture = Highlighter.get_image("tape.png")

	# We select the first character at the start
	if characters.size() > 0:
		select_character(0)


# Called every frame, plays the idle animation of the preview
# The sheet has the normal poses first, then the same poses with the eyes closed
func _process(delta: float) -> void:
	# If no animation is loaded yet, we do nothing
	if idle_frames.size() == 0:
		return

	# We add the time passed since the last frame
	idle_time = idle_time + delta

	# Half of the frames are the normal poses, we change pose every IDLE_FRAME_TIME
	var pose_count: int = int(idle_frames.size() / 2.0)
	var frame: int = int(idle_time / IDLE_FRAME_TIME) % pose_count

	# When it is time to blink, we take the same pose with the eyes closed
	if idle_time >= next_blink:
		frame = frame + pose_count

		# When the blink is over, we choose a random time for the next one
		if idle_time >= next_blink + BLINK_TIME:
			next_blink = idle_time + randf_range(BLINK_DELAY_MIN, BLINK_DELAY_MAX)

	# We show the chosen frame in the preview
	character_preview.texture = idle_frames[frame]


# Loads the four characters from their .tres files
func load_characters() -> void:
	characters.append(load("res://core/data/character1.tres"))
	characters.append(load("res://core/data/character2.tres"))
	characters.append(load("res://core/data/character3.tres"))
	characters.append(load("res://core/data/character4.tres"))


# Creates one row for each stat: the name, the bar and the value
func build_stat_rows() -> void:
	for stat in STATS:
		# Name of the stat on the left
		var name_label: Label = create_label(stat["label"], 30)
		stats_grid.add_child(name_label)

		# Bar of the stat in the middle, without the percent text
		var bar: ProgressBar = ProgressBar.new()
		bar.custom_minimum_size = Vector2(400, 28)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.show_percentage = false
		
		# A multiplier goes from 0.5 to 2, a normal stat from 0 to 100
		if stat["multiplier"]:
			bar.min_value = MULTIPLIER_MIN
			bar.max_value = MULTIPLIER_MAX
			bar.step = 0.01
		else:
			bar.max_value = STAT_MAX
			
		# Light background for the empty part and stat color for the filled part
		bar.add_theme_stylebox_override("background", create_box(BAR_BACKGROUND_COLOR))
		bar.add_theme_stylebox_override("fill", create_box(stat["color"]))
		stats_grid.add_child(bar)

		# Value of the stat on the right
		var value_label: Label = create_label("0", 30)
		value_label.custom_minimum_size.x = 140
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stats_grid.add_child(value_label)

		# We keep the bar and the label to update them when the character changes
		stat_bars[stat["property"]] = bar
		stat_value_labels[stat["property"]] = value_label


# Creates one thumbnail button for each character
func build_thumbnails() -> void:
	# The group makes sure only one thumbnail is pressed at a time
	var group: ButtonGroup = ButtonGroup.new()

	for i in range(characters.size()):
		var character: CharacterData = characters[i]

		# The button stays pressed when clicked and shows the portrait made bigger
		var button: Button = Button.new()
		button.toggle_mode = true
		button.button_group = group
		button.icon = scale_texture(character.portrait, THUMBNAIL_ZOOM)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.custom_minimum_size = THUMBNAIL_SIZE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		# We use the 3 paper images one after the other so the thumbnails are not all the same
		var paper_number: int = i % THUMBNAIL_COUNT + 1
		var paper_path: String = "res://assets/ui/menu/thumb_" + str(paper_number) + ".png"
		var selected_path: String = "res://assets/ui/menu/thumb_selected_" + str(paper_number) + ".png"

		# Normal paper, a bit lighter when hovered, darker when selected
		var paper: StyleBoxTexture = create_paper_box(paper_path)
		var hovered: StyleBoxTexture = create_paper_box(paper_path)
		hovered.modulate_color = HOVERED_PAPER_COLOR
		var selected: StyleBoxTexture = create_paper_box(selected_path)
		selected.modulate_color = SELECTED_PAPER_COLOR

		# We give the button its look for each state, and no frame when it has the focus
		button.add_theme_stylebox_override("normal", paper)
		button.add_theme_stylebox_override("hover", hovered)
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover_pressed", selected)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		# When the thumbnail is pressed, we call _on_thumbnail_pressed with the number i of the character
		button.pressed.connect(_on_thumbnail_pressed.bind(i))

		# We add the button in the row and keep it in the list
		thumbnail_row.add_child(button)
		thumbnails.append(button)


# Shows the character number index: preview, name, description and stats
func select_character(index: int) -> void:
	var character: CharacterData = characters[index]

	# If this character is already selected, we do nothing
	if character == selected_character:
		return

	# We save the new character and press its thumbnail
	selected_character = character
	thumbnails[index].button_pressed = true

	# We update the preview, the texts and the stats
	set_idle_frames(character.idle_sheet)
	character_name_label.text = character.character_name
	character_description.text = character.description
	animate_preview()
	animate_stats(character)


# Moves the stat bars smoothly to the values of the character
func animate_stats(character: CharacterData) -> void:
	# If the bars are still moving, we stop the old animation
	if bars_tween != null:
		bars_tween.kill()

	# All the bars move at the same time and slow down at the end
	bars_tween = create_tween()
	bars_tween.set_parallel(true)
	bars_tween.set_trans(Tween.TRANS_QUAD)
	bars_tween.set_ease(Tween.EASE_OUT)

	for stat in STATS:
		var property: String = stat["property"]

		# We read the stat in the character with its name, for example "sleep"
		var value: float = character.get(property)

		# We write the value next to the bar, then the bar moves to this value
		stat_value_labels[property].text = format_stat(value, stat["multiplier"])
		bars_tween.tween_property(stat_bars[property], "value", value, BAR_ANIMATION_TIME)


# Makes the preview appear with a short fade
func animate_preview() -> void:
	# If the fade is still playing, we stop it
	if preview_tween != null:
		preview_tween.kill()

	# We start invisible and go to fully visible
	character_preview.self_modulate.a = 0.0
	preview_tween = create_tween()
	preview_tween.tween_property(character_preview, "self_modulate:a", 1.0, PREVIEW_FADE_TIME)


# Cuts the idle sheet into square frames for the animation
func set_idle_frames(sheet: Texture2D) -> void:
	# We remove the frames of the old character
	idle_frames.clear()

	# We make the sheet bigger first, then each frame is a square as high as the sheet
	var big_sheet: ImageTexture = scale_texture(sheet, PREVIEW_ZOOM)
	var frame_size: int = big_sheet.get_height()
	var frame_count: int = int(big_sheet.get_width() / float(frame_size))

	for i in range(frame_count):
		# An AtlasTexture shows only one part of the big image
		var frame: AtlasTexture = AtlasTexture.new()
		frame.atlas = big_sheet

		# Each frame is one square further to the right
		frame.region = Rect2(i * frame_size, 0, frame_size, frame_size)
		idle_frames.append(frame)

	# We restart the animation and choose when the first blink happens
	idle_time = 0.0
	next_blink = randf_range(BLINK_DELAY_MIN, BLINK_DELAY_MAX)
	character_preview.texture = idle_frames[0]


# Makes a pixel art image bigger without making it blurry
func scale_texture(texture: Texture2D, factor: int) -> ImageTexture:
	# We take the pixels of the image, make them bigger and create a new texture
	var image: Image = texture.get_image()

	# NEAREST keeps the pixels sharp
	image.resize(image.get_width() * factor, image.get_height() * factor, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


# Turns a stat into text: "×1,50" for a multiplier, "75" for a normal stat
func format_stat(value: float, is_multiplier: bool) -> String:
	if is_multiplier:
		# We keep 2 numbers after the comma and use a French comma
		var text: String = "%.2f" % value
		text = text.replace(".", ",")
		return "×" + text
	else:
		# A normal stat is shown without decimals
		return str(int(value))


# Creates a label with our font and ink color
func create_label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# We change the font, the size and the color of the text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	return label


# Creates a colored box with a border, used for the stat bars
func create_box(color: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = BAR_BORDER_COLOR

	# A border of 2 pixels on each side
	box.set_border_width_all(2)
	return box


# Creates the paper background of a thumbnail from an image
func create_paper_box(texture_path: String) -> StyleBoxTexture:
	var box: StyleBoxTexture = StyleBoxTexture.new()
	box.texture = load(texture_path)

	# Space between the paper border and the portrait
	box.content_margin_left = 16
	box.content_margin_top = 16
	box.content_margin_right = 24
	box.content_margin_bottom = 24
	return box


# Selects the character of the pressed thumbnail
func _on_thumbnail_pressed(index: int) -> void:
	AudioManager.play_click()
	select_character(index)


# Goes back to the mode select screen
func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MODE_SELECT_PATH)


# Saves the chosen character in GameManager
func _on_confirm_pressed() -> void:
	AudioManager.play_click()

	# The game scene will read the chosen character in GameManager
	GameManager.selected_character = selected_character
