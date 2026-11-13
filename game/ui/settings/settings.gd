# Settings screen: volumes, music, highlighter color and credits
extends Control

# Paths of the screens we can go to
const MAIN_MENU_PATH: String = "res://ui/main/main_menu.tscn"
const CREDITS_PATH: String = "res://ui/credits/credits.tscn"

# Transparency of the highlighter color in the dropdown menus
const HIGHLIGHTER_ALPHA: float = 0.7

# Volume sliders with their percent text, dropdowns and buttons of the screen
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var track_option: OptionButton = %TrackOption
@onready var highlighter_option: OptionButton = %HighlighterOption
@onready var credits_button: Button = %CreditsButton
@onready var back_button: Button = %BackButton


# Called when the scene is loaded
func _ready() -> void:
	# We fill the dropdowns, put the highlighter color and show the current values
	setup_track_option()
	setup_highlighter_option()
	update_highlighter()
	load_settings()

	# When a slider moves, we change the volume
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	# When we let go of the sound effects slider, we play a click to hear the new volume
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)
	music_slider.value_changed.connect(_on_music_slider_changed)

	# When a dropdown is opened we play a click, and when an item is chosen we call its function
	track_option.pressed.connect(_on_option_pressed)
	track_option.item_selected.connect(_on_track_selected)
	highlighter_option.pressed.connect(_on_option_pressed)
	highlighter_option.item_selected.connect(_on_highlighter_selected)

	# When a button is pressed, we call its function written below
	credits_button.pressed.connect(_on_credits_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# When the mouse goes on a button it gets highlighted, and when it leaves it is not anymore
	track_option.mouse_entered.connect(track_option.grab_focus)
	track_option.mouse_exited.connect(track_option.release_focus)
	highlighter_option.mouse_entered.connect(highlighter_option.grab_focus)
	highlighter_option.mouse_exited.connect(highlighter_option.release_focus)
	credits_button.mouse_entered.connect(credits_button.grab_focus)
	credits_button.mouse_exited.connect(credits_button.release_focus)
	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)


# Fills the music dropdown with the musics of AudioManager
func setup_track_option() -> void:
	for track in AudioManager.MUSIC_TRACKS:
		track_option.add_item(track["name"])
	remove_radio_marks(track_option)


# Fills the highlighter dropdown with each color and a small colored square
func setup_highlighter_option() -> void:
	for entry in Highlighter.COLORS:
		# The swatch is the small colored square shown next to the name
		var swatch: Texture2D = load(Highlighter.IMAGES_PATH + entry["folder"] + "/swatch.png")
		highlighter_option.add_icon_item(swatch, entry["name"])
	remove_radio_marks(highlighter_option)

	# We select the color used right now
	highlighter_option.select(Highlighter.current_index)


# Removes the little round marks Godot puts in front of the dropdown items
func remove_radio_marks(option: OptionButton) -> void:
	# The items are inside a popup menu that belongs to the dropdown
	var popup: PopupMenu = option.get_popup()
	for i in range(popup.item_count):
		popup.set_item_as_radio_checkable(i, false)


# Puts the current highlighter color on everything in the settings screen
func update_highlighter() -> void:
	var color: Color = Highlighter.get_color()

	# We change the highlighter images of the screen
	Highlighter.apply(self)

	# Color of the hovered item in the dropdown menus
	var popup_hover_box: StyleBoxFlat = theme.get_stylebox("hover", "PopupMenu") as StyleBoxFlat
	popup_hover_box.bg_color = Color(color, HIGHLIGHTER_ALPHA)

	# Color of the filled part of the sliders
	# The two sliders share the same style, so changing one changes both
	var grabber_area: StyleBoxFlat = sfx_slider.get_theme_stylebox("grabber_area") as StyleBoxFlat
	var grabber_area_highlight: StyleBoxFlat = sfx_slider.get_theme_stylebox("grabber_area_highlight") as StyleBoxFlat
	grabber_area.bg_color = color
	grabber_area_highlight.bg_color = color.lightened(0.35)

	# Image of the round handle of the sliders
	var grabber: Texture2D = Highlighter.get_image("slider_grabber.png")
	var grabber_hover: Texture2D = Highlighter.get_image("slider_grabber_hover.png")
	sfx_slider.add_theme_icon_override("grabber", grabber)
	sfx_slider.add_theme_icon_override("grabber_highlight", grabber_hover)
	music_slider.add_theme_icon_override("grabber", grabber)
	music_slider.add_theme_icon_override("grabber_highlight", grabber_hover)


# Turns a value into a text like "80%"
func format_value(value: float) -> String:
	return str(int(value)) + "%"


# Shows the current values of AudioManager in the sliders and dropdown
func load_settings() -> void:
	sfx_slider.value = AudioManager.sfx_volume
	music_slider.value = AudioManager.music_volume
	sfx_value.text = format_value(AudioManager.sfx_volume)
	music_value.text = format_value(AudioManager.music_volume)

	# We select the music playing right now
	track_option.select(AudioManager.current_track_index)


# Changes the sound effects volume and its text
func _on_sfx_slider_changed(value: float) -> void:
	sfx_value.text = format_value(value)
	AudioManager.set_sfx_volume(value)


# Plays a click when we let go of the slider
func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	AudioManager.play_click()


# Changes the music volume and its text
func _on_music_slider_changed(value: float) -> void:
	music_value.text = format_value(value)
	AudioManager.set_music_volume(value)


# Plays a click when a dropdown is opened
func _on_option_pressed() -> void:
	AudioManager.play_click()


# Plays the chosen music
func _on_track_selected(index: int) -> void:
	AudioManager.play_click()
	AudioManager.play_track(index)


# Saves the chosen color and updates the screen
func _on_highlighter_selected(index: int) -> void:
	AudioManager.play_click()
	Highlighter.current_index = index
	update_highlighter()


# Goes back to the main menu
func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


# Goes to the credits screen
func _on_credits_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(CREDITS_PATH)
