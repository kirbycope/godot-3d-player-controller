## https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html#doc-command-line-tutorial-exporting

$godot = "C:\Users\kirby\OneDrive\Desktop\Godot Game Engine.exe"
$preset = "Web"
$project = Split-Path -Path (Get-Location) -Leaf
$path = "C:\GitHub\${project}\ci\${project}.pck"

# Run Godot headless and export the project as a PCK file
Start-Process -FilePath $godot -ArgumentList "--headless", "--export-pack $preset $path" -NoNewWindow -Wait
