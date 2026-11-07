# Credits screen with the names scrolling from bottom to top
extends Control

# Path of the previous screen and font used for the texts
const SETTINGS_PATH: String = "res://ui/settings/settings.tscn"
const FONT: Font = preload("res://assets/font/PixelOperator8.ttf")

# Dark blue color of the text, like a pen
const INK: Color = Color(0.11, 0.14, 0.3)

# Speed of the scrolling in pixels per second
const SCROLL_SPEED: float = 40.0

# Time in seconds before the scrolling starts
const START_PAUSE: float = 1.5

# Content of the credits: a title and its lines for each section
const SECTIONS: Array = [
	{"title": "Équipe", "lines": ["Alexis Danrée", "Yanis Herlin", "Maxime Peignier", "Lucas Treiber-Lustig"]},
	{"title": "Projet", "lines": ["Projet T3 - BUT Informatique", "IUT Robert Schuman"]},
	{"title": "Police d'écriture", "lines": ["Pixel Operator 8"]},
	{"title": "Moteur de jeu", "lines": ["Godot Engine"]},
	{"title": "Merci d'avoir joué !", "lines": []},
]

# Area that hides what goes out, list of the names and back button
@onready var scroller: Control = %Scroller
@onready var credits_list: VBoxContainer = %CreditsList
@onready var back_button: Button = %BackButton

# Time left before the scrolling starts
var wait_time: float = START_PAUSE


# Called when the scene is loaded
func _ready() -> void:
	build_credits()

	# When the back button is pressed, we call _on_back_pressed
	back_button.pressed.connect(_on_back_pressed)

	# When the mouse goes on the button it gets highlighted, and when it leaves it is not anymore
	back_button.mouse_entered.connect(back_button.grab_focus)
	back_button.mouse_exited.connect(back_button.release_focus)

	# We put the chosen highlighter color on the screen
	Highlighter.apply(self)


# Called every frame, delta is the time since the last frame
func _process(delta: float) -> void:
	# We wait a little before starting to scroll
	if wait_time > 0:
		wait_time = wait_time - delta
		return

	# We move the list up
	credits_list.position.y = credits_list.position.y - SCROLL_SPEED * delta

	# When the list is completely out at the top, we put it back at the bottom
	if credits_list.position.y < -credits_list.size.y:
		credits_list.position.y = scroller.size.y


# Creates the labels of the credits from the SECTIONS list
func build_credits() -> void:
	var title_box: StyleBoxTexture = create_title_box()

	for section in SECTIONS:
		# The title of the section with a highlighter stroke behind it
		var title: Label = create_label(section["title"], 36)
		title.add_theme_stylebox_override("normal", title_box)
		credits_list.add_child(title)

		# The lines of the section
		for line in section["lines"]:
			var line_label: Label = create_label(line, 28)
			credits_list.add_child(line_label)

		# An empty space between two sections
		var spacer: Control = Control.new()
		spacer.custom_minimum_size.y = 30
		credits_list.add_child(spacer)


# Creates the highlighter stroke shown behind the titles
func create_title_box() -> StyleBoxTexture:
	var box: StyleBoxTexture = StyleBoxTexture.new()
	box.texture = Highlighter.get_image("credits_highlight.png")

	# The margins keep the ends of the stroke from being stretched
	box.texture_margin_left = 48
	box.texture_margin_right = 64

	# Space between the stroke and the text
	box.content_margin_left = 72
	box.content_margin_right = 80
	box.content_margin_top = 20
	box.content_margin_bottom = 27
	return box


# Creates a centered label with our font and ink color
func create_label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text

	# The label stays in the middle and only takes the size of its text
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# We change the font, the size and the color of the text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", INK)
	return label


# Goes back to the settings screen
func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file(SETTINGS_PATH)
