extends Node

const DEFAULT_SFX: float = 80.0
const DEFAULT_MUSIC: float = 20.0

const MUSIC_TRACKS: Array = [
	{"name": "Musique 1", "path": "res://assets/music/backgroundSound3.mp3"},
	{"name": "Musique 2", "path": "res://assets/music/backgroundSound2.mp3"},
	{"name": "Musique 3", "path": "res://assets/music/backgroundSound1.mp3"},
	{"name": "Musique 4", "path": "res://assets/music/backgroundSound4.mp3"},
	{"name": "Musique 5", "path": "res://assets/music/backgroundSound5.mp3"},
]

var music_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var current_track_index: int = 0
var sfx_volume: float = DEFAULT_SFX
var music_volume: float = DEFAULT_MUSIC


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.finished.connect(_on_music_finished)
	add_child(music_player)

	click_player = AudioStreamPlayer.new()
	click_player.stream = load("res://assets/sounds/pressButton.mp3")
	click_player.bus = "SFX"
	add_child(click_player)

	set_sfx_volume(DEFAULT_SFX)
	set_music_volume(DEFAULT_MUSIC)
	play_track(0)


func play_click() -> void:
	click_player.play()


func play_track(index: int) -> void:
	index = clampi(index, 0, MUSIC_TRACKS.size() - 1)
	if index == current_track_index and music_player.playing:
		return

	current_track_index = index
	music_player.stream = load(MUSIC_TRACKS[index]["path"])
	music_player.play()


func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	set_bus_volume("SFX", value)


func set_music_volume(value: float) -> void:
	music_volume = value
	set_bus_volume("Music", value)


func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	var volume_db: float = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

	if value <= 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)


func _on_music_finished() -> void:
	music_player.play()
