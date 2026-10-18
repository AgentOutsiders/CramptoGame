extends Node

const SAVE_PATH := "user://settings.cfg"

# Musiques proposées dans les paramètres : nom affiché et fichier
const MUSIC_TRACKS := [
	{"name": "Musique 1", "path": "res://assets/music/backgroundSound3.mp3"},
	{"name": "Musique 2", "path": "res://assets/music/backgroundSound2.mp3"},
	{"name": "Musique 3", "path": "res://assets/music/backgroundSound1.mp3"},
]

var music_player := AudioStreamPlayer.new()
var click_player := AudioStreamPlayer.new()
var current_track_index := 0


func _ready() -> void:
	music_player.bus = "Music"
	music_player.finished.connect(music_player.play)  # rejoue la musique en boucle
	add_child(music_player)

	click_player.stream = load("res://assets/sounds/pressButton.mp3")
	click_player.bus = "SFX"
	add_child(click_player)

	_load_settings()


func play_click() -> void:
	click_player.play()


func play_track(index: int) -> void:
	index = clampi(index, 0, MUSIC_TRACKS.size() - 1)
	if index == current_track_index and music_player.playing:
		return
	current_track_index = index
	music_player.stream = load(MUSIC_TRACKS[index].path)
	music_player.play()


func apply_volume(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))
	AudioServer.set_bus_mute(bus_index, value <= 0)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var sfx := 90.0
	var music := 80.0
	if config.load(SAVE_PATH) == OK:
		sfx = config.get_value("audio", "sfx", sfx)
		music = config.get_value("audio", "music", music)
	apply_volume("SFX", sfx)
	apply_volume("Music", music)
	play_track(0)  # on démarre toujours sur la musique 1, quel que soit le choix précédent
