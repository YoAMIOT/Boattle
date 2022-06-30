extends Node

var profileFile : String = "user://profile.save";
var settingsFile : String = "user://settings.save";
var serversFile : String = "user://servers.save";
var ipDictionnary : Dictionary;
var datas : Dictionary = {
	"playerName" : "",
	"fullscreen" : true,
	"vSync" : true,
	"windowSize" : Vector2(1920, 1080),
};


func _ready():
	var file : File = File.new();
	if file.file_exists(settingsFile):
		var error = file.open(settingsFile, File.READ);
		printError(error);
		datas = file.get_var();
		file.close();
		OptionManager.setFullscreen(datas["fullscreen"]);
		OptionManager.setWindowSize(datas["windowSize"]);
	if file.file_exists(serversFile):
		var error = file.open(serversFile, File.READ);
		printError(error);
		ipDictionnary = file.get_var();
		file.close();




func savePlayerName(newName : String):
	datas["playerName"] = newName;
	saveSettings();

func saveFullscreen(fullscreenState : bool):
	datas["fullscreen"] = fullscreenState;
	saveSettings();

func saveVsync(state : bool):
	datas["vSync"] = state;
	saveSettings();

func saveWindowSize(size : Vector2):
	datas["windowSize"] = size;
	saveSettings();

func saveSettings():
	var file : File = File.new();
	var error = file.open(settingsFile, File.WRITE);
	printError(error);
	file.store_var(datas);
	file.close();



func addToDictionnary(key : String, address : String):
	ipDictionnary[key] = address;
	var file : File = File.new();
	var error = file.open(serversFile, File.WRITE);
	printError(error);
	file.store_var(ipDictionnary);
	file.close();



func printError(error):
	if error != 0:
		print("ERROR: ", error);
