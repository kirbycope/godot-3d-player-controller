extends Node
## The `Globals` singleton serves to hold variables and functions.
##
## Globals is a singleton, which is a globally accessible object that exists for
## the entire duration of the game. It allows you to store data and functions
## that you want to be available across different scenes and scripts without
## having to pass them around manually.
## @tutorial: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

## The Client scene.
var client:
	get:
		return get_node_by_path_name("root/Client")

## Flag for if the app was opened in Debug mode.
var debug_mode: bool = OS.is_debug_build()

## Flag for if the game has a fixed camera.
var fixed_camera: bool = false

## Flag for if the game is Paused.
var game_paused: bool = false

## Flag for if the game has Started.
var game_started: bool = false

## The Main scene.
var main:
	get:
		return get_node_by_path_name("root/Main")

## Flag for if the player's movement is locked
var movement_locked: bool = false

## The current time in RFC 3339 format.
var time_stamp_utc: bool = true
var time_stamp: String:
	get:
		var return_value = Time.get_datetime_string_from_system(time_stamp_utc)
		return return_value + "Z" if time_stamp_utc else return_value


## Gets the scene by the path's concatenated name.
func get_node_by_path_name(concatenated_name: String):
	var children = get_tree().root.get_children()
	for child in children:
		if child.get_path().get_concatenated_names() == concatenated_name:
			return child


## Get the "Player3D" or "Player2D".
func get_player():
	var player = get_parent().find_child("Player3D", true, false)
	if player == null:
		player = get_parent().find_child("Player2D", true, false)
	return player


## Plays the given audio file using an ephemeral audio player.
func play_audio(resourse: String):

	# Create a new AudioStreamPlayer
	var sfx_player := AudioStreamPlayer.new()

	# Load the sound from the file path
	sfx_player.stream = load(resourse)

	# Add the sound player to the scene
	add_child(sfx_player)

	# Tell the sound player to remove the itself when it's finished
	sfx_player.finished.connect(sfx_player.queue_free)

	# Play the sound
	sfx_player.play()


## Plays the given resource on the Music player.
func play_music(resourse: String):
	var music_player = null
	# Get sound player if app loaded from $Client
	if client:
		music_player = client.get_node("Main").get_node("Music")
	else:
		music_player = main.get_node("Music")
	music_player.stream = load(resourse)
	music_player.play()


## Plays the given resource on the Sound player.
func play_sound(resourse: String):
	var sound_player = null
	# Get sound player if app loaded from $Client
	if client:
		sound_player = client.get_node("Main").get_node("Sound")
	else:
		sound_player = main.get_node("Sound")
	sound_player.stream = load(resourse)
	sound_player.play()
