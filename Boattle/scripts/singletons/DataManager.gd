extends Node

var profileFile : String = "user://profile.save";
var settingsFile : String = "user://settings.save";
var serversFile : String = "user://servers.save";
var ipDictionnary : Dictionary;
var datas : Dictionary = {
	"playerName" : "",
	"fullscreen" : true,
	"vSync" : true,
};


func _ready():
	var file : File = File.new();
	if file.file_exists(settingsFile):
		file.open(settingsFile, File.READ);
		datas = file.get_var();
		file.close();
		OptionManager.setFullscreen(datas["fullscreen"]);
	if file.file_exists(serversFile):
		file.open(serversFile, File.READ);
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

func saveSettings():
	var file : File = File.new();
	file.open(settingsFile, File.WRITE);
	file.store_var(datas);
	file.close();



func addToDictionnary(key : String, address : String):
	ipDictionnary[key] = address;
	var file : File = File.new();
	file.open(serversFile, File.WRITE);
	file.store_var(ipDictionnary);
	file.close();
