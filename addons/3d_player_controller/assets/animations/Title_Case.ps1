Set-Location -Path "C:\GitHub\godot-3d-player-controller\assets\mixamo\animations"
Get-ChildItem -Filter "*.import" | ForEach-Object {
    $currentName = $_.Name
    $newName = (Get-Culture).TextInfo.ToTitleCase($_.BaseName.ToLower()).Replace(' ', '_') + ".fbx"
    if (Test-Path $newName) {
        pass
    } else {
        Rename-Item -Path $_.FullName -NewName $newName
    }
}