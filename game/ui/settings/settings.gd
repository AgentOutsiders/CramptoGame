extends Control

const MAIN_MENU_PATH: String = "res://ui/main/main_menu.tscn"
const CREDITS_PATH: String = "res://ui/credits/credits.tscn"
const HIGHLIGHTER_ALPHA: float = 0.7

@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var track_option: OptionButton = %TrackOption
@onready var highlighter_option: OptionButton = %HighlighterOption
@onready var credits_button: Button = %CreditsButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	setup_track_option()
	setup_highlighter_option()
	update_highlighter()
	load_settings()

	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)
	music_slider.value_changed.connect(_on_music_slider_changed)

	track_option.pressed.connect(_on_option_pressed)
	track_option.item_selected.connect(_on_track_selected)
	highlighter_option.pressed.connect(_on_option_pressed)
	highlighter_option.item_selected.connect(_on_highlighter_selected)

	credits_button.pressed.connect(_on_credits_pressed)
	back_button.pressed.connect(_on_back_pressed)

	track_option.mouse_entered.connect(track_option.grab_focus)
	track_option.mouse_exited.connect(track_option.release_focus)
	highlighter_option.mouse_entered.connect(highlighter_option.grab_focus)
	highlighter_option.mouse_exited.connect(highlighter_option.release_focus)
	credits_button.mouse_entered.connect(credits_button.grab_focus)
	credits_button.mouse_exited.connect(credits_button.release_focus)
	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)


func setup_track_option() -> void:
	for track in AudioManager.MUSIC_TRACKS:
		track_option.add_item(track["name"])
	remove_radio_marks(track_option)


func setup_highlighter_option() -> void:
	for entry in Highlighter.COLORS:
		var swatch: Texture2D = load(Highlighter.IMAGES_PATH + entry["folder"] + "/swatch.png")
		highlighter_option.add_icon_item(swatch, entry["name"])
	remove_radio_marks(highlighter_option)
	highlighter_option.select(Highlighter.current_index)


func remove_radio_marks(option: OptionButton) -> void:
	var popup: PopupMenu = option.get_popup()
	for i in range(popup.item_count):
		popup.set_item_as_radio_checkable(i, false)


func update_highlighter() -> void:
	var color: Color = Highlighter.get_color()
	Highlighter.apply(self)

	var popup_hover_box: StyleBoxFlat = theme.get_stylebox("hover", "PopupMenu") as StyleBoxFlat
	popup_hover_box.bg_color = Color(color, HIGHLIGHTER_ALPHA)

	var grabber_area: StyleBoxFlat = sfx_slider.get_theme_stylebox("grabber_area") as StyleBoxFlat
	var grabber_area_highlight: StyleBoxFlat = sfx_slider.get_theme_stylebox("grabber_area_highlight") as StyleBoxFlat
	grabber_area.bg_color = color
	grabber_area_highlight.bg_color = color.lightened(0.35)

	var grabber: Texture2D = Highlighter.get_image("slider_grabber.png")
	var grabber_hover: Texture2D = Highlighter.get_image("slider_grabber_hover.png")
	sfx_slider.add_theme_icon_override("grabber", grabber)
	sfx_slider.add_theme_icon_override("grabber_highlight", grabber_hover)
	music_slider.add_theme_icon_override("grabber", grabber)
	music_slider.add_theme_icon_override("grabber_highlight", grabber_hover)


func format_value(value: float) -> String:
	return str(int(value)) + "%"


func load_settings() -> void:
	sfx_slider.value = AudioManager.sfx_volume
	music_slider.value = AudioManager.music_volume
	sfx_value.text = format_value(AudioManager.sfx_volume)
	music_value.text = format_value(AudioManager.music_volume)
	track_option.select(AudioManager.current_track_index)


func _on_sfx_slider_changed(value: float) -> void:
	sfx_value.text = format_value(value)
	AudioManager.set_sfx_volume(value)


func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	AudioManager.play_click()


func _on_music_slider_changed(value: float) -> void:
	music_value.text = format_value(value)
	AudioManager.set_music_volume(value)


func _on_option_pressed() -> void:
	AudioManager.play_click()


func _on_track_selected(index: int) -> void:
	AudioManager.play_click()
	AudioManager.play_track(index)


func _on_highlighter_selected(index: int) -> void:
	AudioManager.play_click()
	Highlighter.current_index = index
	update_highlighter()


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_credits_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(CREDITS_PATH)
