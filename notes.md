# Notes
1. Download fbx from mixamo.com
	- [Characters](https://www.mixamo.com/#/?page=1&type=Character), upload your own and let Mixamo rig it or download one of the samples
		- Save as `assets/characters/{model_name}.fbx`
			- Format: `FBX Binary(.fbx)`
			- Pose: `T-pose`
	- [Animations](https://www.mixamo.com/#/?page=1&type=Motion%2CMotionPack), no skins
		- Save as `assets/characters/{Animation_Name}.fbx`
		- `_In_Place` variants made by checking "In Place"
		- `_Left` and `_Right` variants used by checking "Mirror"

## Prepare Character
1. In the "FileSystem", double-click your rigged character
1. Select "Retarget" > "Bone Map" > "New BoneMap"
1. Select the BoneMap
1. Select "Profile" > "New SkeletonProfileHumanoid"
1. Select "Reimport
1. Create a new 3D Scene
1. Drag the rigged character from the "FileSystem" to the "Scene" tree
1. Right-click on the rigged character and select "Make Local"
1. Select the "root" node and select "Make Scene Root"
1. Delete the old root element (Node3D)

## Prepare Animation
1. Select the animation in the FileSystem
1. Select the Import tab
1. Change to "Animation Library"
1. Select "Reimport"
1. In the "FileSystem", double-click your animation
1. Select "Retarget" > "Bone Map" > "New BoneMap"
1. Select the BoneMap
1. Select "Profile" > "New SkeletonProfileHumanoid"
1. Select "Reimport

## Add Animation to Model
1. In the "Scene" tree, select the character's AnimationPlayer
1. Select "Animation" > "Manage Animations..."
1. Select "Load Library"
1. Find and select your animation(s)

## Add Model to Player Scene
1. In the "FileSystem", double-click `player_3d.tscn`
1. Replace "AuxScene" with your character
	- Keep the "AuxScene" name (scripts reference it)

----

## Controls
|    Action		|  Virtual/XBox	|    Keyboard/Mouse		|
| Debug			|				| F3					|
| DPAD_UP		| DPAD_UP		| Tab					|
| DPAD_DOWN		| DPAD_DOWN		| Q						|
| DPAD_LEFT		| DPAD_LEFT		| B						|
| DPAD_RIGHT	| DPAD_RIGHT	| T						|
| MOVE_UP		| L.JOY_UP		| W						|
| MOVE_DOWN		| L.JOY_DOWN	| S						|
| MOVE_LEFT		| L.JOY_LEFT	| A						|
| MOVE_RIGHT	| L.JOY_RIGHT	| D						|
| Select		| Select		| F5					|
| Start			| Start			| Esc					|
| LOOK_UP		| R.JOY_UP		| Up/Mouse				|
| LOOK_DOWN		| R.JOY_DOWN	| Down/Mouse			|
| LOOK_LEFT		| R.JOY_LEFT	| Left/Mouse			|
| LOOK_RIGHT	| R.JOY_RIGHT	| Right/Mouse			|
| Jump			| A				| Space					|
| Sprint		| B				| Shift					|
| Crouch		| Y				| Ctrl					|
| Use			| X				| E						|
| Left Punch	| L1			| Mouse-button left		|
| Left Kick		| L2			| Mouse-button xbutton2	|
| Aim			| L2			| Mouse-button right	|
| Zoom In		| L3			| Mouse-scroll down		|
| Right Punch	| L1			| Mouse-button right	|
| Right Kick	| R2			| Mouse-button xbutton1	|
| Shoot			| R2			| Mouse-button left		|
| Zoom Out		| R3			| Mouse-scroll up		|
