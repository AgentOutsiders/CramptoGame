extends Control

const SETTINGS_PATH: String = "res://ui/settings/settings.tscn"
const FONT: Font = preload("res://assets/font/PixelOperator8.ttf")
const INK: Color = Color(0.11, 0.14, 0.3)
const SCROLL_SPEED: float = 40.0
const START_PAUSE: float = 1.5

const SECTIONS: Array = [
	{"title": "Équipe", "lines": ["Alexis Danrée", "Yanis Herlin", "Maxime Peignier", "Lucas Treiber-Lustig"]},
	{"title": "Projet", "lines": ["Projet T3 - BUT Informatique", "IUT Robert Schuman"]},
	{"title": "Police d'écriture", "lines": ["Pixel Operator 8"]},
	{"title": "Moteur de jeu", "lines": ["Godot Engine"]},
	{"title": "Merci d'avoir joué !", "lines": []},
]

@onready var scroller: Control = %Scroller
@onready var credits_list: VBoxContainer = %CreditsList
@onready var back_button: Button = %BackButton

var wait_time: float = START_PAUSE


func _ready() -> void:
	build_credits()

	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)

	Highlighter.apply(self)


func _process(delta: float) -> void:
	if wait_time > 0:
		wait_time = wait_time - delta
		return

	credits_list.position.y = credits_list.position.y - SCROLL_SPEED * delta

	if credits_list.position.y < -credits_list.size.y:
		credits_list.position.y = scroller.size.y


func build_credits() -> void:
	var title_box: StyleBoxTexture = create_title_box()

	for section in SECTIONS:
		var title: Label = create_label(section["title"], 36)
		title.add_theme_stylebox_override("normal", title_box)
		credits_list.add_child(title)

		for line in section["lines"]:
			var line_label: Label = create_label(line, 28)
			credits_list.add_child(line_label)

		var spacer: Control = Control.new()
		spacer.custom_minimum_size.y = 30
		credits_list.add_child(spacer)


func create_title_box() -> StyleBoxTexture:
	var box: StyleBoxTexture = StyleBoxTexture.new()
	box.texture = Highlighter.get_image("credits_highlight.png")
	box.texture_margin_left = 48
	box.texture_margin_right = 64
	box.content_margin_left = 72
	box.content_margin_right = 80
	box.content_margin_top = 20
	box.content_margin_bottom = 27
	return box


func create_label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	return label


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(SETTINGS_PATH)
