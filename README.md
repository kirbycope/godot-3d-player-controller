![Thumbnail](/ci/thumbnail.png)

# godot-3d-player-controller
A 3D Player Controller for the Godot game engine.

## Getting Started
Copy the contents of this repo's `/addons` folder to the `/addons` folder of your project. No need to "activate" it in Godot > Project Settings... > Plugins.

### Updating Dependencies
Note: You can add this repo and any others to [/ci/requirements.txt](/ci/requirements.txt) to help keep things up to date in your project.
1. Open a terminal window
1. Run `./ci/install-requirements.sh`

## Player Structure
![CharacterBody3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/CharacterBody3D.svg)
[CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html) `Player` - ([player_3d.gd](/addons/3d_player_controller/player_3d.gd))<br/>
├── ![AudioStreamPlayer3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/AudioStreamPlayer3D.svg)
	[AudioStreamPlayer3D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html) `AudioStreamPlayer3D`<br/>
├── ![Node3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Node3D.svg)
	[Node3D](https://docs.godotengine.org/en/stable/classes/class_node.html) `CameraMount`<br/>
│  └── ![Camera3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Camera3D.svg)
		[Camera3D]() Camera3D (<a href="/addons/3d_player_controller/camera_3d.gd">camera_3d.gd</a>)<br/>
│  └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
		[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `ChatWindow` (<a href="/addons/3d_player_controller/chat_window.gd">chat_window.gd</a>)<br/>
│    └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
			[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `Message` (<a href="/addons/3d_player_controller/message.gd">message.gd</a>)<br/>
│  └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
		[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `Debug` (<a href="/addons/3d_player_controller/debug.gd">debug.gd</a>)<br/>
│  └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
		[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `Emotes` (<a href="/addons/3d_player_controller/emotes.gd">emotes.gd</a>)<br/>
│  └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
		[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `Pause` (<a href="/addons/3d_player_controller/pause.gd">pause.gd</a>)<br/>
│  └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
		[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `Retical`</br>
│  └── ![Control](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Control.svg)
		[Control](https://docs.godotengine.org/en/stable/classes/class_control.html) `Settings` (<a href="/addons/3d_player_controller/settings.gd">settings.gd</a>)<br/>
├── ![CollisionShape3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/CollisionShape3D.svg)
	`CollisionShape3D` CollisionShape3D<br/>
├── ![CanvasLayer](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/CanvasLayer.svg)
	`CanvasLayer` Controls (<a href="/addons/virtual_controller/scripts/controls.gd">controls.gd</a>)<br/>
├── ![ShapeCast3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/ShapeCast3D.svg)
	`ShapeCast3D` ShapeCast3D<br/>
├── ![Node](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Node.svg)
	`Node` States<br/>
└── ![Node3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Node3D.svg)
	`Node3D` Visuals<br/>
  └── ![Node3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Node3D.svg)
		`Node3D` AuxScene<br/>
    └── ![AnimationPlayer](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/AnimationPlayer.svg)
		`AnimationPlayer` AnimationPlayer<br/>

- `$CameraMount` shares its origin with _Lukky_'s [Godot 4.0 Third Person Controller Tutorial (2023)](https://www.youtube.com/watch?v=EP5AYllgHy8)
- `$Controls` is as imported scene from the [Virtual Controller](https://github.com/kirbycope/godot-virtual-controller) addon
	- [controls.gd](/addons/virtual_controller/scripts/controls.gd) Handles defining default control scheme for Controllers, Keyboard+Mouse, and Touchsceen devices.
	- [canvas_layer.tscn](/addons/virtual_controller/scenes/canvas_layer.tscn) Displays the virtual controller when a touchscreen device is in use.
- `$ShapeCast3D` comes from _Peter Clark_'s [Godot 4.3 Fast Simple Stairs Tutorial 3D](https://www.youtube.com/watch?v=38BN96kQANc)
- `$States` was inspired by _softgripper_'s [take on the StateMachine pattern](https://www.reddit.com/r/godot/comments/1hg0c7g/my_take_on_the_statemachine_pattern/)

## Changing the Player's Model
The player's appearance comes from the imported scene, `$Visuals/AuxScene`. [Retargetting](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html) the skeleton will allow you to use the provided animations and sets you up to use others like _Quaternius's_ [Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html).
1. Open the Godot Editor
1. Click the character model in the FileSystem
1. Click the "Import" tab (at the top-right of the editor)
1. Click the "Advanced..." button
1. In the Scene tree, select the ![Skeleton3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Skeleton3D.svg) Skeleton3D
1. Click "Retarget" > "Bone Map" > "<empty>" and then select "New" > "BoneMap"
1. Click the new BoneMap
1. Click "Profile" > "⏷" and then select "SkeletonProfileHumanoid"
1. Click the "Reimport" button to apply changes
1. Click the "Scene" tab (at the top-right of the editor)
1. Create a new ![Node3D](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/Node3D.svg) 3D Scene
1. Drag your model into the new Scene tree
1. Right-click the model and select "Make Local"
1. Right-click the model and then select "Make Scene Root"
1. Delete the Node3D now at the bottom of the Scene tree
1. Select the scene root and set the "Transform" > "Rotation" > "y" to `180`
	- Godot's "forward" direction is -Z ([source](https://docs.godotengine.org/en/stable/tutorials/3d/introduction_to_3d.html#coordinate-system))
1. Add a child ![AnimationPlayer](https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/AnimationPlayer.svg) AnimationPlayer if one is not already present
1. In the Scene tree, click the AnimationPlayer
1. In the Animation Panel, click the "Animation" button and then select "Manage Animations..."
1. Click the "Load Library" button
1. Navigate to `./addons/3d_player_controller/assets/animations`
1. Select all and then click the "Open" button
1. Save the scene
1. Open the Player scene and expand "Player" > "Visuals"
1. Delete the "AuxScene"
1. From the FileSystem, drag your new scene into the Player scene tree under "Visuals"
1. Rename it to `AuxScene` so the existing scripts don't break
	- Or change the path `@onready var visuals_aux_scene = ...` in the [player.gd](/addons/3d_player_controller/player_3d.gd) script.

----

<details>
<summary>Web Hosting with localhost</summary>

### Install and Enable Live Server
[Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) allows you to host web pages, locally, from VSCode.

### Running/Hosting the App Locally
1. In VSCode's Explorer right-click on [docs/index.html](docs/index.html) and select "Open with Live Server"
1. Then you visit [https://127.0.0.1:5500/docs/index.html](https://127.0.0.1:5500/docs/index.html)
1. To get your "Host Local IP Address", use terminal to run:
	- [Windows] `ipconfig`
	- [MacOS] `ipconfig getifaddr en0`
1. On a device connected to the same wifi as the host, navigate to `https://{host.local.ip.address}:5500/docs/index.html`
	- Replace `{host.local.ip.address}` with your "Host Local IP Address" from earlier

</details>

<details>
<summary>Access localhost from Devices on Same Wifi Network</summary>

### Generate HTTPS Certificate
"Secure Context - Check web server configuration (use HTTPS)" The following features required to run Godot projects on the Web. Do the following to setup
1. Download and install the [ssl binary](https://wiki.openssl.org/index.php/Binaries)
	- [Windows] Use [OpenSSL for Windows](https://slproweb.com/products/Win32OpenSSL.html)
	- [MacOS] Use [Homebrew](https://brew.sh/) by running, `brew install openssl@3`
1. Confirm installation by running `openssl -v` in cmd/terminal
1. Open the root folder using [VS Code](https://code.visualstudio.com/)
	- If you use GitHub Desktop, select the "Open in Visual Studio" button
1. Open the [integrated terminal](https://code.visualstudio.com/docs/editor/integrated-terminal)
1. Run `openssl genrsa -aes256 -out localhost.key 2048`
	- You will be prompted for a "PEM pass phrase", remember this for the next step
	- `godot`
1. Run `openssl req -days 3650 -new -newkey rsa:2048 -key localhost.key -x509 -out localhost.pem`
	- You will be prompted for the "PEM pass phrase"
	- Fill out the rest of the information as the prompts request
		- "Country Name (2 letter code) [AU]:"`US`
		- "State or Province Name (full name) [Some-State]:"`WA`
		- "Locality Name (eg, city) []:"`Seattle`
		- "Organization Name (eg, company) [Internet Widgits Pty Ltd]:"`Timothy Cope`
		- "Organizational Unit Name (eg, section) []:"`Development`
		- "Common Name (e.g. server FQDN or YOUR name) []:"`localhost`
		- "Email Address []:"`kirbycope@gmail.com`
1. Open/Create `.vscode/settings.json` in the root of your project
1. Copy+paste the following:
	```
	{
		"liveServer.settings.root": "/",
		"liveServer.settings.https": {
			"enable": true,
			"cert": "{path/to/your/}localhost.pem",
			"key": "{path/to/your/}localhost.key",
			"passphrase": "{PEM pass phrase}"
		}
	}
	```
	- Replace `{PEM pass phrase}` with your "PEM pass phrase" from earlier
1. Restart VSCode (or the terminal, at least)

</details>

<details>
<summary>Web Hosting with GitHub Pages</summary>

### Set Up GitHub Pages
Note: This only needs to be done once.
1. Go to the "Settings" tab of the repo
1. Select "Pages" from left-nav
1. Select `main` branch and `/docs` directory, then select "Save"
	- A GitHub Action will deploy your website
1. On the main page of the GitHub repo, click the gear icon next to "About"
1. Select "Use your GitHub Pages website", then select "Save changes"

</details>
