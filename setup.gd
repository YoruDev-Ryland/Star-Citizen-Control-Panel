extends Control

var regex = RegEx.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_browse_btn_pressed():
	$FileDialog.current_dir = "C:\\"
	$FileDialog.visible = true


func _on_file_dialog_file_selected(path):
	regex.compile("StarCitizen/LIVE/")
	var result = regex.search(path)
	if result:
		$VBoxContainer/HBoxContainer/SCFolderLEdit.text = path.left(-29)
		Globals.gameDirectory = path.left(-29)
	else:
		regex.compile("StarCitizen/PTU/")
		result = regex.search(path)
		if result:
			$VBoxContainer/HBoxContainer/SCFolderLEdit.text = path.left(-28)
			Globals.gameDirectory = path.left(-28)
		else:
			regex.compile("StarCitizen/EPTU/")
			result = regex.search(path)
			if result:
				$VBoxContainer/HBoxContainer/SCFolderLEdit.text = path.left(-29)
				Globals.gameDirectory = path.left(-29)
			else:
				$VBoxContainer/WarningLbl.text = "We couldn't locate your LIVE/PTU/EPTU folders. Please fix your shit."
				return
	
	var dir = DirAccess.open(Globals.gameDirectory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				match file_name:
					"LIVE":
						Globals.liveDirectory = Globals.gameDirectory + file_name + "/"
					"PTU":
						Globals.ptuDirectory = Globals.gameDirectory + file_name + "/"
					"EPTU":
						Globals.eptuDirectory = Globals.gameDirectory + file_name + "/"
			else:
				pass
			file_name = dir.get_next()


func _on_save_btn_pressed():
	if($VBoxContainer/HBoxContainer/SCFolderLEdit.text == ""):
		$VBoxContainer/WarningLbl.text = "Please select your StarCitizen_Launcher.exe"
		return
	
	var config = {
		"GameDirectory": Globals.gameDirectory,
		"ControlsDirectory": Globals.controlsDirectory,
		"LIVEDirectory": Globals.liveDirectory,
		"PTUDirectory": Globals.ptuDirectory,
		"EPTUDirectory": Globals.eptuDirectory
	}
	var json_string = JSON.stringify(config)
	
	var file = FileAccess.open(Globals.config_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
	get_tree().change_scene_to_file("res://main.tscn")
