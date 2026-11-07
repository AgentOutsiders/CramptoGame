# Autoload that keeps the player choices between the scenes
extends Node

# The two game modes: STORY has an end, INFINITE never ends
enum GameMode { STORY, INFINITE }

# Mode chosen in the mode select screen
var selected_mode: GameMode = GameMode.STORY

# Character chosen in the character select screen
var selected_character: CharacterData = null
