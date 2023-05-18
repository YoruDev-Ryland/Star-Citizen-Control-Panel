extends Node

var config_path = OS.get_user_data_dir() + "/config.json"
var controlsDirectory = "USER/Client/0/Controls/Mappings/"
var gameDirectory = ""
var liveDirectory = ""
var ptuDirectory = ""
var eptuDirectory = ""
var selectedVersion = ""
var controlsBackupDirectory = ""
var selectedVersionControlsDirectory = ""
var localAppdataPath = ""

func _ready():
	# Set shadercache directory
	var drive = "C:/"
	var user = OS.get_environment("USERNAME")
	localAppdataPath = drive + "users/" + user + "/appdata/local/Star Citizen"


func _process(_delta):
	pass
