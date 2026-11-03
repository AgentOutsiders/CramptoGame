extends Node

const IMAGES_PATH: String = "res://assets/ui/highlighter/"

const COLORS: Array = [
	{"name": "Bleu", "folder": "bleu", "color": Color(0.35, 0.78, 1)},
	{"name": "Jaune", "folder": "jaune", "color": Color(1, 0.91, 0.16)},
	{"name": "Vert", "folder": "vert", "color": Color(0.5, 0.92, 0.3)},
	{"name": "Orange", "folder": "orange", "color": Color(1, 0.6, 0.18)},
	{"name": "Rose", "folder": "rose", "color": Color(1, 0.48, 0.78)},
	{"name": "Violet", "folder": "violet", "color": Color(0.72, 0.5, 1)},
	{"name": "Rouge", "folder": "rouge", "color": Color(1, 0.3, 0.27)},
]

const STYLE_NAMES: Array = ["focus", "pressed", "hover_pressed"]

var current_index: int = 0


func get_color() -> Color:
	return COLORS[current_index]["color"]


func get_folder() -> String:
	return IMAGES_PATH + COLORS[current_index]["folder"] + "/"


func get_image(file_name: String) -> Texture2D:
	return load(get_folder() + file_name)


func apply(node: Node) -> void:
	if node is Control:
		var control: Control = node as Control
		for style_name in STYLE_NAMES:
			if control.has_theme_stylebox_override(style_name):
				var box: StyleBoxTexture = control.get_theme_stylebox(style_name) as StyleBoxTexture
				if box != null and box.texture != null:
					var path: String = box.texture.resource_path
					if path.begins_with(IMAGES_PATH):
						box.texture = get_image(path.get_file())

	for child in node.get_children():
		apply(child)
