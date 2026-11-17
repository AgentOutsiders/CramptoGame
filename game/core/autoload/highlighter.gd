# Autoload that manages the highlighter color chosen in the settings
# Each color has its own folder with the same images already colored
extends Node

# Folder with one sub folder for each color
const IMAGES_PATH: String = "res://assets/ui/highlighter/"

# List of the colors: name shown in the menu, image folder, and real color
const COLORS: Array = [
	{"name": "Bleu", "folder": "bleu", "color": Color(0.35, 0.78, 1)},
	{"name": "Jaune", "folder": "jaune", "color": Color(1, 0.91, 0.16)},
	{"name": "Vert", "folder": "vert", "color": Color(0.5, 0.92, 0.3)},
	{"name": "Orange", "folder": "orange", "color": Color(1, 0.6, 0.18)},
	{"name": "Rose", "folder": "rose", "color": Color(1, 0.48, 0.78)},
	{"name": "Violet", "folder": "violet", "color": Color(0.72, 0.5, 1)},
	{"name": "Rouge", "folder": "rouge", "color": Color(1, 0.3, 0.27)},
]

# Button styles that use a highlighter image
const STYLE_NAMES: Array = ["focus", "pressed", "hover_pressed"]

# Index of the current color in the COLORS list
var current_index: int = 0


# Returns the current highlighter color
func get_color() -> Color:
	return COLORS[current_index]["color"]


# Returns the image folder of the current color
func get_folder() -> String:
	return IMAGES_PATH + COLORS[current_index]["folder"] + "/"


# Loads an image from the folder of the current color
func get_image(file_name: String) -> Texture2D:
	return load(get_folder() + file_name)


# Puts the current color on a node and on all its children
# The function calls itself on each child, so it goes through the whole scene
func apply(node: Node) -> void:
	# Only Control nodes like buttons have styles
	if node is Control:
		var control: Control = node as Control

		# We check each style that can use a highlighter image
		for style_name in STYLE_NAMES:
			if control.has_theme_stylebox_override(style_name):
				var box: StyleBoxTexture = control.get_theme_stylebox(style_name) as StyleBoxTexture
				if box != null and box.texture != null:
					var path: String = box.texture.resource_path

					# If the image is a highlighter image, we take the same file in the new color folder
					if path.begins_with(IMAGES_PATH):
						box.texture = get_image(path.get_file())

	# We do the same thing for every child of the node
	for child in node.get_children():
		apply(child)
