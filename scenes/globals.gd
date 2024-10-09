extends Node
## The `Globals` singleton serves to hold variables and functions.
##
## Globals is a singleton, which is a globally accessible object that exists for
## the entire duration of the game. It allows you to store data and functions
## that you want to be available across different scenes and scripts without
## having to pass them around manually.
## @tutorial: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html


## Flag for if the app was opened in Debug mode.
var debug_mode: bool = OS.is_debug_build()

## Flag for if the current scene has a fixed camera.
var fixed_camera: bool = false

## Flag for if the game is Paused.
var game_paused: bool = false

## Flag for if the player's movement is locked
var movement_locked: bool = false

## The current time in RFC 3339 format.
var time_stamp_utc: bool = true
var time_stamp: String:
	get:
		var return_value = Time.get_datetime_string_from_system(time_stamp_utc)
		return return_value + "Z" if time_stamp_utc else return_value
