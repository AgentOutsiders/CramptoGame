extends Control

const SAVE_PATH := "user://settings.cfg"
const MAIN_MENU_PATH := "res://ui/main/main_menu.tscn"
const INK := Color(0.11, 0.14, 0.3)
const PAPER := Color(0.965, 0.95, 0.9)
const HIGHLIGHTER := Color(1, 0.91, 0.16, 0.7)

@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var track_option: OptionButton = %TrackOption
@onready var back_button: Button = %BackButton


func _ready() -> void:
	for slider in [sfx_slider, music_slider]:
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 1

	_setup_track_option()
	load_settings()

	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.drag_ended.connect(func(_changed): AudioManager.play_click())
	track_option.item_selected.connect(_on_track_selected)
	track_option.pressed.connect(AudioManager.play_click)
	back_button.pressed.connect(_on_back_pressed)

	# Surligneur (style « focus ») sur l'élément survolé par la souris
	for control in [track_option, back_button]:
		control.mouse_entered.connect(control.grab_focus)
		control.mouse_exited.connect(control.release_focus)


func _setup_track_option() -> void:
	for track in AudioManager.MUSIC_TRACKS:
		track_option.add_item(track.name)

	track_option.add_theme_icon_override("arrow", _create_arrow_icon())
	track_option.add_theme_constant_override("arrow_margin", 36)  # l'ombre du papier occupe le bord droit

	# La liste qui s'ouvre reprend le style de la page
	var popup := track_option.get_popup()
	for i in popup.item_count:
		popup.set_item_as_radio_checkable(i, false)  # pas de puce devant les pistes
	var font: Font = track_option.get_theme_font("font")
	popup.add_theme_font_override("font", font)
	popup.add_theme_font_size_override("font_size", 28)
	popup.add_theme_color_override("font_color", INK)
	popup.add_theme_color_override("font_hover_color", INK)
	popup.add_theme_constant_override("v_separation", 16)
	var panel := StyleBoxFlat.new()
	panel.bg_color = PAPER
	panel.set_border_width_all(3)
	panel.border_color = INK
	panel.set_content_margin_all(12)
	popup.add_theme_stylebox_override("panel", panel)
	var hover := StyleBoxFlat.new()
	hover.bg_color = HIGHLIGHTER
	popup.add_theme_stylebox_override("hover", hover)


# Flèche pixel art (triangle pointant vers le bas)
func _create_arrow_icon() -> ImageTexture:
	var image := Image.create(20, 10, false, Image.FORMAT_RGBA8)
	for y in 10:
		for x in range(y, 20 - y):
			image.set_pixel(x, y, INK)
	return ImageTexture.create_from_image(image)


func _on_sfx_changed(value: float) -> void:
	sfx_value.text = _format_value(value)
	AudioManager.apply_volume("SFX", value)
	save_settings()


func _on_music_changed(value: float) -> void:
	music_value.text = _format_value(value)
	AudioManager.apply_volume("Music", value)
	save_settings()


func _on_track_selected(index: int) -> void:
	AudioManager.play_click()
	AudioManager.play_track(index)
	save_settings()


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "sfx", sfx_slider.value)
	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "track", AudioManager.current_track_index)
	config.save(SAVE_PATH)


func load_settings() -> void:
	var config := ConfigFile.new()
	var sfx := 90.0
	var music := 80.0
	if config.load(SAVE_PATH) == OK:
		sfx = config.get_value("audio", "sfx", sfx)
		music = config.get_value("audio", "music", music)
	sfx_slider.value = sfx
	music_slider.value = music
	sfx_value.text = _format_value(sfx)
	music_value.text = _format_value(music)
	track_option.select(AudioManager.current_track_index)


func _format_value(value: float) -> String:
	return "%d%%" % int(value)
