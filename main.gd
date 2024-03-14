extends Control

# ------------------------------------------------------------------------------------------------#
# Begin Node Variable References
# ------------------------------------------------------------------------------------------------#
@onready var popup = $PopupPanel
@onready var titleLabel = $PopupPanel/VBoxContainer/titleLabel
@onready var topLabel = $PopupPanel/VBoxContainer/topLabel
@onready var hbox = $PopupPanel/VBoxContainer/ButtonHBox


# ------------------------------------------------------------------------------------------------#
# Begin Built-in Functions
# ------------------------------------------------------------------------------------------------#
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_min_size(Vector2(1280, 720))
	# Get configuration from file
	if FileAccess.file_exists(Globals.config_path):
		var file = FileAccess.open(Globals.config_path, FileAccess.READ)
		var content = file.get_as_text()
		
		var json = JSON.new()
		
		var error = json.parse(content)
		if error == OK:
			var data_received = json.data
			Globals.gameDirectory = data_received["GameDirectory"]
			Globals.liveDirectory = data_received["LIVEDirectory"]
			Globals.eptuDirectory = data_received["EPTUDirectory"]
			Globals.ptuDirectory = data_received["PTUDirectory"]
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
		file.close()
		
		scan_Game_Versions()
		update_Control_Boxes(Globals.selectedVersion)
	else:
		get_tree().change_scene_to_file("res://setup.tscn")
	
	_update_Globals()
	
	# If backup directory in appdata doesn't exist, create it.
	if !DirAccess.dir_exists_absolute(Globals.controlsBackupDirectory):
		DirAccess.make_dir_recursive_absolute(Globals.controlsBackupDirectory)


# ------------------------------------------------------------------------------------------------#
# Begin Shadercache Deletion Section DONE DONE
# ------------------------------------------------------------------------------------------------#
func _on_del_shaders_btn_pressed():
	_update_Globals()
	_clear_element(hbox)
	
	titleLabel.text = "Delete Shadercache"
	topLabel.text = "This will delete your shadercache folder, are you sure?" # Warn and ask for approval
	
	spawnButton("Yes", "_confirm_shadercache_delete_button_pressed", {})
	
	# Create the Cancel Button
	spawnButton("Cancel", "_cancel_button_pressed", {})
	popup.popup_centered()


func _confirm_shadercache_delete_button_pressed():
	if DirAccess.dir_exists_absolute(Globals.localAppdataPath):
		topLabel.text = "Deleting Shadercache, please wait."
		
		delete_files(Globals.localAppdataPath)
		
		topLabel.text = "Shadercache has been deleted."
		
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()
	else:
		topLabel.text = "Shadercache not found or already deleted."
		
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()


# ------------------------------------------------------------------------------------------------#
# Begin User Folder Deletion Section DONE DONE
# ------------------------------------------------------------------------------------------------#
func _on_del_user_btn_pressed():
	_update_Globals()
	_clear_element(hbox)
	
	titleLabel.text = "Delete User Folder"
	topLabel.text = "Which user folder are you wishing to delete?" # Warn and ask for approval
	
	for i in range($MenuBar/GameSelector.get_item_count()): # for each option
		spawnButton($MenuBar/GameSelector.get_item_text(i), "_confirm_user_delete_button_pressed", {"version": $MenuBar/GameSelector.get_item_text(i)})
	
	# Create the Cancel Button
	spawnButton("Cancel", "_cancel_button_pressed", {})
	popup.popup_centered()


func _confirm_user_delete_button_pressed(properties):
	match properties["version"]:
		"LIVE":
			if DirAccess.dir_exists_absolute(Globals.liveDirectory+"USER"):
				backup_files(Globals.liveDirectory+Globals.controlsDirectory, Globals.controlsBackupDirectory+"Temp/")
				
				delete_files(Globals.liveDirectory+"USER")
				
				#backup_files(Globals.controlsBackupDirectory+"Temp/", Globals.liveDirectory+Globals.controlsDirectory)
				
				topLabel.text = "The " + properties["version"] + " user folder has been deleted."
				
				_clear_element(hbox)
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
			else:
				topLabel.text = "The " + properties["version"] + " user folder could not be found or has already been deleted."
				
				_clear_element(hbox)
				
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
		"PTU":
			if DirAccess.dir_exists_absolute(Globals.ptuDirectory+"USER"):
				backup_files(Globals.ptuDirectory+Globals.controlsDirectory, Globals.controlsBackupDirectory+"Temp/")
				
				delete_files(Globals.ptuDirectory+"USER")
				
				backup_files(Globals.controlsBackupDirectory+"Temp/", Globals.ptuDirectory+Globals.controlsDirectory)
				
				topLabel.text = "The " + properties["version"] + " user folder has been deleted."
				
				_clear_element(hbox)
				
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
			else:
				topLabel.text = "The " + properties["version"] + " user folder could not be found or has already been deleted."
				
				_clear_element(hbox)
				
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
		"EPTU":
			if DirAccess.dir_exists_absolute(Globals.eptuDirectory+"USER"):
				backup_files(Globals.eptuDirectory+Globals.controlsDirectory, Globals.controlsBackupDirectory+"Temp/")
				
				delete_files(Globals.eptuDirectory+"USER")
				
				backup_files(Globals.controlsBackupDirectory+"Temp/", Globals.eptuDirectory+Globals.controlsDirectory)
				
				topLabel.text = "The " + properties["version"] + " user folder has been deleted."
				
				_clear_element(hbox)
				
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
			else:
				topLabel.text = "The " + properties["version"] + " user folder could not be found or has already been deleted."
				
				_clear_element(hbox)
				
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()


# ------------------------------------------------------------------------------------------------#
# Begin Convert Install Section DONE DONE
# ------------------------------------------------------------------------------------------------#
func _on_convert_btn_pressed():
	_update_Globals()
	_clear_element(hbox)
	
	titleLabel.text = "Convert Game Install"
	topLabel.text = "Use this function to save on disk space and download time when switching between LIVE/PTU/EPTU installs.\n\nWhat install would you like to convert?" # Warn and ask for selection
	
	for i in range($MenuBar/GameSelector.get_item_count()): # for each option
		spawnButton($MenuBar/GameSelector.get_item_text(i), "_select_install_to_convert", {"fromversion": $MenuBar/GameSelector.get_item_text(i)})
	
	spawnButton("Cancel", "_cancel_button_pressed", {})
	popup.popup_centered()


func _select_install_to_convert(properties):
	_clear_element(hbox)
	
	topLabel.text = "What would you like to convert this install too?" # Warn and ask for selection
	
	match properties["fromversion"]:
		"LIVE":
			spawnButton("PTU", "_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": "PTU"})
			spawnButton("EPTU", "_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": "EPTU"})

		"PTU":
			spawnButton("LIVE", "_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": "LIVE"})
			spawnButton("EPTU", "_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": "EPTU"})
		"EPTU":
			spawnButton("LIVE", "_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": "LIVE"})
			spawnButton("PTU", "_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": "PTU"})

	
	# Create the Cancel Button
	spawnButton("Cancel", "_cancel_button_pressed", {})

	popup.popup_centered()


func _convert_install_button_pressed(properties):
	match properties["fromversion"]:
		"LIVE":
			if DirAccess.dir_exists_absolute(Globals.gameDirectory+properties["toversion"]):
				_clear_element(hbox)
				
				topLabel.text = "You already have an install at this location, would you like to replace it? This will delete your " + properties["toversion"] + " install." # Warn and ask for approval
				
				spawnButton("Yes", "_confirm_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": properties["toversion"]})
				
				# Create the Cancel Button
				spawnButton("Cancel", "_cancel_button_pressed", {})
				popup.popup_centered()
			else:
				topLabel.text = "Converting, please wait."
				var fromVersionDirectory = Globals.gameDirectory + properties["fromversion"]
				rename_files(fromVersionDirectory, properties["toversion"])
				
				topLabel.text = "Conversion complete. Please verify files in the launcher."
				
				# Create the Ok Button
				_clear_element(hbox)
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
		"PTU":
			if DirAccess.dir_exists_absolute(Globals.gameDirectory+properties["toversion"]):
				_clear_element(hbox)
				
				topLabel.text = "You already have an install at this location, would you like to replace it?" # Warn and ask for approval
				
				spawnButton("Yes", "_confirm_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": properties["toversion"]})
				
				# Create the Cancel Button
				spawnButton("Cancel", "_cancel_button_pressed", {})
				popup.popup_centered()
			else:
				topLabel.text = "Converting, please wait."
				var fromVersionDirectory = Globals.gameDirectory + properties["fromversion"]
				rename_files(fromVersionDirectory, properties["toversion"])
				
				topLabel.text = "Conversion complete. Please verify files in the launcher."
				
				# Create the Ok Button
				_clear_element(hbox)
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()
		"EPTU":
			if DirAccess.dir_exists_absolute(Globals.gameDirectory+properties["toversion"]):
				_clear_element(hbox)
				
				topLabel.text = "You already have an install at this location, would you like to replace it?" # Warn and ask for approval
				
				spawnButton("Yes", "_confirm_convert_install_button_pressed", {"fromversion": properties["fromversion"], "toversion": properties["toversion"]})
				
				# Create the Cancel Button
				spawnButton("Cancel", "_cancel_button_pressed", {})
				popup.popup_centered()
			else:
				topLabel.text = "Converting, please wait."
				var fromVersionDirectory = Globals.gameDirectory + properties["fromversion"]
				rename_files(fromVersionDirectory, properties["toversion"])
				
				topLabel.text = "Conversion complete. Please verify files in the launcher."
				
				# Create the Ok Button
				_clear_element(hbox)
				spawnButton("Ok", "_cancel_button_pressed", {})
				popup.popup_centered()


func _confirm_convert_install_button_pressed(properties):
	topLabel.text = "Deleting, please wait."
	var fromVersionDirectory = Globals.gameDirectory + properties["fromversion"]
	var toVersionDirectory = Globals.gameDirectory + properties["toversion"]
	delete_files(toVersionDirectory)
	rename_files(fromVersionDirectory, properties["toversion"])
	
	topLabel.text = "Old directory deleted and conversion complete."
	
	# Create the Ok Button
	_clear_element(hbox)
	spawnButton("Ok", "_cancel_button_pressed", {})
	popup.popup_centered()


# ------------------------------------------------------------------------------------------------#
# Begin SCCP Reset Section DONE DONE
# ------------------------------------------------------------------------------------------------#
func _on_reset_btn_pressed():
	_update_Globals()
	_clear_element(hbox)
	
	titleLabel.text = "Reset Star Citizen Control Panel"
	topLabel.text = "This will delete your Star Citizen Control Panel config, are you sure?" # Warn and ask for approval
	
	spawnButton("Yes", "_confirm_config_delete_button_pressed", {})
	
	# Create the Cancel Button
	spawnButton("Cancel", "_cancel_button_pressed", {})
	popup.popup_centered()


func _confirm_config_delete_button_pressed():
	if FileAccess.file_exists(Globals.config_path):
		topLabel.text = "Deleting config, please wait."
		
		delete_files(Globals.config_path)
		
		topLabel.text = "Config has been deleted."
		
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()
	else:
		topLabel.text = "Config not found or already deleted."
		
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()


# ------------------------------------------------------------------------------------------------#
# Begin Control Button Section DONE DONE
# ------------------------------------------------------------------------------------------------#
# Get popup for when control button is pressed (Cannot convert to function buttons)
func _control_button_pressed(button_text: String, location: String):
	popup.visible = true
	titleLabel.text = "Choose an action"
	topLabel.text = "Currently modifying: " + button_text
	_clear_element(hbox)
	
	match location:
		"Game":
			for i in range(4): # for each option
				var button = Button.new() # create a new Button
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL # make the button expand horizontally
				var buttonNumber = i + 1
				match buttonNumber:
					1:
						button.text = "Copy" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Game")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
					2:
						button.text = "Backup" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Game")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
					3:
						button.text = "Delete" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Game")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
					4:
						button.text = "Cancel" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Game")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
			popup.popup_centered()
		"Backup":
			for i in range(3): # for each option
				var button = Button.new() # create a new Button
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL # make the button expand horizontally
				var buttonNumber = i + 1
				match buttonNumber:
					1:
						button.text = "Copy" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Backup")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
					2:
						button.text = "Delete" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Backup")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
					3:
						button.text = "Cancel" # set its text
						button.connect("pressed", func(): _control_function_button_pressed(button.text, button_text, "Backup")) # connect its pressed signal
						hbox.add_child(button) # add it to the HBoxContainer
			popup.popup_centered()


func _control_function_button_pressed(button_text: String, controlProfileClicked: String, location: String):
	match button_text:
		"Copy": # Copying control file from one place to another
			match location:
				"Game": # The control button clicked was in the game(top) controlbox
					_clear_element(hbox)
					
					titleLabel.text = "Where do you want to copy to?"
					topLabel.text = ""
					
					for i in range($MenuBar/GameSelector.get_item_count()): # for each option
						if ($MenuBar/GameSelector.get_item_text(i) == Globals.selectedVersion): # Skip selected version for this since you don't want to copy it to the same place
							pass
						else:
							spawnButton($MenuBar/GameSelector.get_item_text(i), "_copy_button_pressed", {"location": location, "buttonText": $MenuBar/GameSelector.get_item_text(i), "controlProfileClicked": controlProfileClicked})
					
					# Create the Cancel Button
					spawnButton("Cancel", "_cancel_button_pressed", {})
					popup.popup_centered()
					
				"Backup": # The control button clicked was in the backup(bottom) controlbox
					_clear_element(hbox)
					
					titleLabel.text = "Where do you want to copy to?"
					topLabel.text = ""
					
					for i in range($MenuBar/GameSelector.get_item_count()): # List all options since you are in the backup controlbox
						spawnButton($MenuBar/GameSelector.get_item_text(i), "_copy_button_pressed", {"location": location, "buttonText": $MenuBar/GameSelector.get_item_text(i), "controlProfileClicked": controlProfileClicked})
					
					# Create the Cancel Button
					spawnButton("Cancel", "_cancel_button_pressed", {})
					popup.popup_centered()
			
			# If file exists, warn
			# Copy file to selected game version
			
		"Backup":
			# If backup exists, warn
			# Save file to backup directory
			titleLabel.text = "Backing up Controls"
			
			copy_files(Globals.gameDirectory+Globals.selectedVersion+"/"+Globals.controlsDirectory+controlProfileClicked, Globals.controlsBackupDirectory)
			
			titleLabel.text = "Backup Complete"
			topLabel.text = controlProfileClicked + " has been backed up."
			
			_clear_element(hbox)
			
			spawnButton("Ok", "_cancel_button_pressed", {})
			
			popup.popup_centered()
		"Delete":
			titleLabel.text = "Delete " + controlProfileClicked + "?"
			
			topLabel.text = "This will delete this controller profile, are you sure?"
			
			_clear_element(hbox)
			
			spawnButton("Yes, delete.", "_confirm_delete_button_pressed", {"controlProfileClicked": controlProfileClicked, "location": location})
			spawnButton("Cancel", "_cancel_button_pressed", {})
			
			popup.popup_centered()
		"Cancel":
			_cancel_button_pressed()

func _confirm_delete_button_pressed(properties):
	match properties["location"]:
		"Game":
			delete_files(Globals.gameDirectory+Globals.selectedVersion+"/"+Globals.controlsDirectory+properties["controlProfileClicked"])
	
			update_Control_Boxes(Globals.selectedVersion)
			
			titleLabel.text = properties["controlProfileClicked"] + " has been deleted."
			topLabel.text = ""
			
			_clear_element(hbox)
			
			spawnButton("Ok", "_cancel_button_pressed", {})
			popup.popup_centered()
		"Backup":
			delete_files(Globals.controlsBackupDirectory+properties["controlProfileClicked"])
	
			update_Control_Boxes(Globals.selectedVersion)
			
			titleLabel.text = properties["controlProfileClicked"] + " has been deleted."
			topLabel.text = ""
			
			_clear_element(hbox)
			
			spawnButton("Ok", "_cancel_button_pressed", {})
			popup.popup_centered()

# ------------------------------------------------------------------------------------------------#
# Begin Control Copy Section DONE
# ------------------------------------------------------------------------------------------------#
func _copy_button_pressed(properties):
	match properties["location"]:
		"Game":
			match properties["buttonText"]:
				"LIVE":
					_copyFiles(Globals.gameDirectory + Globals.selectedVersion + "/", Globals.controlsDirectory, Globals.liveDirectory + Globals.controlsDirectory, properties["controlProfileClicked"])
				"PTU":
					_copyFiles(Globals.gameDirectory + Globals.selectedVersion + "/", Globals.controlsDirectory, Globals.ptuDirectory + Globals.controlsDirectory, properties["controlProfileClicked"])
				"EPTU":
					_copyFiles(Globals.gameDirectory + Globals.selectedVersion + "/", Globals.controlsDirectory, Globals.eptuDirectory + Globals.controlsDirectory, properties["controlProfileClicked"])
		"Backup":
			match properties["buttonText"]:
				"LIVE":
					_copyFiles(Globals.controlsBackupDirectory, "", Globals.liveDirectory + Globals.controlsDirectory, properties["controlProfileClicked"])
				"PTU":
					_copyFiles(Globals.controlsBackupDirectory, "", Globals.ptuDirectory + Globals.controlsDirectory, properties["controlProfileClicked"])
				"EPTU":
					_copyFiles(Globals.controlsBackupDirectory, "", Globals.eptuDirectory + Globals.controlsDirectory, properties["controlProfileClicked"])


func _copyFiles(sourceDir: String, sourceSubDir: String, destinationDir: String, selectedControlFile: String):
	var sourcePathAndFile = sourceDir + sourceSubDir + selectedControlFile
	var destinationPathAndFile = destinationDir + selectedControlFile
	if FileAccess.file_exists(destinationPathAndFile):
		topLabel.text = "file exists, would you like to overwrite?:\n" + selectedControlFile # Warn and ask for approval later
		_clear_element(hbox)
		spawnButton("Yes", "_confirm_copy_overwrite_button_pressed", {"sourcePathAndFile": sourcePathAndFile, "destinationDir": destinationDir, "selectedControlFile": selectedControlFile})
		
		# Create the Cancel Button
		spawnButton("Cancel", "_cancel_button_pressed", {})
		popup.popup_centered()
	else:
		if !DirAccess.dir_exists_absolute(destinationDir):
			DirAccess.make_dir_recursive_absolute(destinationDir)
		
		copy_files(sourcePathAndFile, destinationDir)
		
		topLabel.text = "Copied: " + selectedControlFile
		
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()


func _confirm_copy_overwrite_button_pressed(properties):
	if !DirAccess.dir_exists_absolute(properties["destinationDir"]):
		DirAccess.make_dir_recursive_absolute(properties["destinationDir"])
		
	copy_files(properties["sourcePathAndFile"], properties["destinationDir"])
		
	topLabel.text = "Copied: " + properties["selectedControlFile"]
	
	_clear_element(hbox)
	
	spawnButton("Ok", "_cancel_button_pressed", {})
	popup.popup_centered()


# ------------------------------------------------------------------------------------------------#
# Begin Control Backup Section DONE
# ------------------------------------------------------------------------------------------------#
func _on_backup_controls_btn_pressed():
	_update_Globals()
	check_user_mappings()
	for i in range($MenuBar/GameSelector.get_item_count()): # List all options since you are in the backup controlbox
		$MenuBar/GameSelector.get_item_text(i)
		backup_files(Globals.gameDirectory+$MenuBar/GameSelector.get_item_text(i)+"/"+Globals.controlsDirectory, Globals.controlsBackupDirectory)
	
	if check_user_mappings():
		update_Control_Boxes(Globals.selectedVersion)
		
		titleLabel.text = "Controller Mappings Backed Up"
		topLabel.text = "All of your controller mapping profiles from all detected installs have been backed up."
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()


# ------------------------------------------------------------------------------------------------#
# Begin Refresh Section DONE
# ------------------------------------------------------------------------------------------------#
func _on_refresh_btn_pressed():
	update_Control_Boxes(Globals.selectedVersion)


# ------------------------------------------------------------------------------------------------#
# Begin General Universal Functions
# ------------------------------------------------------------------------------------------------#
func _on_game_selector_item_selected(index):
	match $MenuBar/GameSelector.get_item_text(index):
		"LIVE":
			Globals.selectedVersion = "LIVE"
		"PTU":
			Globals.selectedVersion = "PTU"
		"EPTU":
			Globals.selectedVersion = "EPTU"
	update_Control_Boxes(Globals.selectedVersion)


func _cancel_button_pressed():
	_clear_element(hbox)
	popup.hide()


func _update_Globals():
	scan_Game_Versions()
	update_Control_Boxes(Globals.selectedVersion)
	_update_Selected_Game_Version()
	Globals.controlsBackupDirectory = OS.get_user_data_dir() + "/ControlsBackup/"
	Globals.selectedVersionControlsDirectory = Globals.gameDirectory + Globals.selectedVersion + "/" + Globals.controlsDirectory


func _update_Selected_Game_Version():
	match $MenuBar/GameSelector.get_selected_id():
		0:
			Globals.selectedVersion = $MenuBar/GameSelector.get_item_text(0)
		1:
			Globals.selectedVersion = $MenuBar/GameSelector.get_item_text(1)
		2:
			Globals.selectedVersion = $MenuBar/GameSelector.get_item_text(2)


func _clear_element(object):
	# get all children of the VBoxContainer
	var children = object.get_children()
	# iterate over each child
	for child in children:
		child.queue_free()


func scan_Game_Versions():
	$MenuBar/GameSelector.clear()
	var dir = DirAccess.open(Globals.gameDirectory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				match file_name:
					"LIVE":
						Globals.liveDirectory = Globals.gameDirectory + file_name + "/"
						$MenuBar/GameSelector.get_popup().add_item("LIVE")
					"PTU":
						Globals.ptuDirectory = Globals.gameDirectory + file_name + "/"
						$MenuBar/GameSelector.get_popup().add_item("PTU")
					"EPTU":
						Globals.eptuDirectory = Globals.gameDirectory + file_name + "/"
						$MenuBar/GameSelector.get_popup().add_item("EPTU")
			else:
				pass
			file_name = dir.get_next()
	$MenuBar/GameSelector.select(0)


func update_Control_Boxes(_activeversion: String):
	_update_Selected_Game_Version()
	Globals.controlsBackupDirectory = OS.get_user_data_dir() + "/ControlsBackup/"
	Globals.selectedVersionControlsDirectory = Globals.gameDirectory + Globals.selectedVersion + "/" + Globals.controlsDirectory
	
	### Game Directory Control Box ###
	
	# get all children of the VBoxContainer
	var children = $VBoxContainer2/GamePanel/VBoxContainer.get_children()
	# iterate over each child
	for child in children:
		# if the child is a Button, remove it
		if child is Button:
			child.queue_free()
	if DirAccess.dir_exists_absolute(Globals.selectedVersionControlsDirectory):
		var i = 0
		while i < DirAccess.get_files_at(Globals.selectedVersionControlsDirectory).size():
			var button = Button.new()
			button.text = DirAccess.get_files_at(Globals.selectedVersionControlsDirectory)[i]
			var button_text = button.text  # Store the button text in a variable
			button.connect("pressed", func(): _control_button_pressed(button_text, "Game"))  # Connect with a lambda function
			$VBoxContainer2/GamePanel/VBoxContainer.add_child(button)
			i += 1
	
	### Backup Directory Control Box ###
	
	# get all children of the VBoxContainer
	children = $VBoxContainer2/BackupPanel/VBoxContainer.get_children()
	# iterate over each child
	for child in children:
		# if the child is a Button, remove it
		if child is Button:
			child.queue_free()
	
	var i = 0
	while i < DirAccess.get_files_at(Globals.controlsBackupDirectory).size():
		var button = Button.new()
		button.text = DirAccess.get_files_at(Globals.controlsBackupDirectory)[i]
		var button_text = button.text  # Store the button text in a variable
		button.connect("pressed", func(): _control_button_pressed(button_text, "Backup"))  # Connect with a lambda function
		$VBoxContainer2/BackupPanel/VBoxContainer.add_child(button)
		i += 1


func copy_files(copyfrom: String, copyto: String):
	if !DirAccess.dir_exists_absolute(copyto):
			DirAccess.make_dir_recursive_absolute(copyto)
	
	OS.execute("powershell.exe", ["Copy-Item", "-Path", "'"+copyfrom+"'", "-Destination", "'"+copyto+"'"])
	update_Control_Boxes(Globals.selectedVersion)


func move_files(movefrom: String, moveto: String):
	if !DirAccess.dir_exists_absolute(moveto):
			DirAccess.make_dir_recursive_absolute(moveto)
			
	OS.execute("powershell.exe", ["Move-Item", "-Path", "'"+movefrom+"'", "-Destination", "'"+moveto+"'"])


func delete_files(deletefiles: String):
	OS.execute("powershell.exe", ["Remove-Item", "-Recurse", "-Force", "'"+deletefiles+"'"])


func rename_files(renamefrom: String, renameto: String):
	OS.execute("powershell.exe", ["Rename-Item", "'"+renamefrom+"'", "'"+renameto+"'"])


func backup_files(fromDir: String, toDir: String):
	if !DirAccess.dir_exists_absolute(toDir):
		DirAccess.make_dir_recursive_absolute(toDir)
		
	var files = DirAccess.get_files_at(fromDir)
	
	for file in files:
		var sourcePath = fromDir + file
		
		if FileAccess.file_exists(toDir):
			print("file exists, not copying: " + file) # Warn and ask for approval later
		else:
			copy_files(sourcePath, toDir)


func spawnButton(buttonName: String, buttonFunction: String, buttonBindings: Dictionary):
	if buttonBindings == {}:
		var callable = Callable(self, buttonFunction)
		create_button(buttonName, callable)
		popup.popup_centered()
	else:
		var callable = Callable(self, buttonFunction).bind(buttonBindings)
		create_button(buttonName, callable)
		popup.popup_centered()


func create_button(buttonText: String, buttonFunction: Callable):
	var button = Button.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = buttonText
	button.pressed.connect(buttonFunction)
	hbox.add_child(button)


func check_user_mappings():
	titleLabel.text = ""
	var file_count = 0
	for i in range($MenuBar/GameSelector.get_item_count()): # for each option
		var dir = DirAccess.open(Globals.gameDirectory+$MenuBar/GameSelector.get_item_text(i)+"/"+Globals.controlsDirectory)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					file_count += 1
				file_name = dir.get_next()
			dir.list_dir_end()
	if (file_count == 0):
		titleLabel.text = "No controller mappings found in game files"
		topLabel.text = "Please make sure you save your controller profiles in order for SCCP to locate them.\nClick the info button to learn how to export your controls."
		_clear_element(hbox)
		
		spawnButton("Ok", "_cancel_button_pressed", {})
		popup.popup_centered()
		
		return false
	else:
		return true


# ------------------------------------------------------------------------------------------------#
# Begin External Links
# ------------------------------------------------------------------------------------------------#
func _on_coffee_btn_pressed():
	OS.shell_open("https://www.buymeacoffee.com/gravekeepers")


func _on_ccu_game_btn_pressed():
	OS.shell_open("https://ccugame.app/")


func _on_rsi_website_btn_pressed():
	OS.shell_open("https://robertsspaceindustries.com/")


func _on_the_impound_btn_pressed():
	OS.shell_open("https://theimpound.com/")


func _on_star_hanger_btn_pressed():
	OS.shell_open("https://star-hangar.com/")


func _on_exportlink_btn_pressed():
	OS.shell_open("https://support.robertsspaceindustries.com/hc/en-us/articles/360000183328-Create-export-and-import-custom-profiles")
