# Autoload that plays the music and the click sound in every scene
# Other scripts call it with AudioManager.play_click() for example
extends Node

# Default volumes in percent, used at every launch
const DEFAULT_SFX: float = 80.0
const DEFAULT_MUSIC: float = 20.0

# List of the musics we can choose in the settings
const MUSIC_TRACKS: Array = [
	{"name": "Musique 1", "path": "res://assets/music/backgroundSound3.mp3"},
	{"name": "Musique 2", "path": "res://assets/music/backgroundSound2.mp3"},
	{"name": "Musique 3", "path": "res://assets/music/backgroundSound1.mp3"},
	{"name": "Musique 4", "path": "res://assets/music/backgroundSound4.mp3"},
	{"name": "Musique 5", "path": "res://assets/music/backgroundSound5.mp3"},
]

# Players for the music and the click sound, created in _ready
var music_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

# Music playing right now and current volumes
var current_track_index: int = 0
var sfx_volume: float = DEFAULT_SFX
var music_volume: float = DEFAULT_MUSIC


# Called once when the game starts
func _ready() -> void:
	# We create the player for the music and put it on the Music bus
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"

	# When the music ends, we call _on_music_finished to play it again
	music_player.finished.connect(_on_music_finished)
	add_child(music_player)

	# We create the player for the click sound and put it on the SFX bus
	click_player = AudioStreamPlayer.new()
	click_player.stream = load("res://assets/sounds/pressButton.mp3")
	click_player.bus = "SFX"
	add_child(click_player)

	# We set the default volumes and start the first music
	set_sfx_volume(DEFAULT_SFX)
	set_music_volume(DEFAULT_MUSIC)
	play_track(0)


# Plays the click sound when a button is pressed
func play_click() -> void:
	click_player.play()


# Plays the music number index from the MUSIC_TRACKS list
func play_track(index: int) -> void:
	# We make sure the index stays inside the list
	index = clampi(index, 0, MUSIC_TRACKS.size() - 1)

	# If this music is already playing, we do nothing
	if index == current_track_index and music_player.playing:
		return

	# We remember the new music, load it and play it
	current_track_index = index
	music_player.stream = load(MUSIC_TRACKS[index]["path"])
	music_player.play()


# Changes the volume of the sound effects
func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	set_bus_volume("SFX", value)


# Changes the volume of the music
func set_music_volume(value: float) -> void:
	music_volume = value
	set_bus_volume("Music", value)


# Changes the volume of an audio bus with a value between 0 and 100
func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	# Godot uses decibels, so we convert the percent into decibels
	var volume_db: float = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

	# At 0 we mute the bus completely
	if value <= 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)


# Called when the music ends, we play it again so it loops
func _on_music_finished() -> void:
	music_player.play()
