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
