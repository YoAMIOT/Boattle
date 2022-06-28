extends Node

var settingsFile : String = "user://settings.save";
var serversFile : String = "user://servers.save";
var playerName : String;
var ipDictionnary : Dictionary;



func _ready():
	var file : File = File.new();
	if file.file_exists(settingsFile):
		file.open(settingsFile, File.READ);
		playerName = file.get_var();
		file.close();
	if file.file_exists(serversFile):
		file.open(serversFile, File.READ);
		ipDictionnary = file.get_var();
		file.close();



func savePlayerName():
	var file : File = File.new();
	file.open(settingsFile, File.WRITE);
	file.store_var(playerName);
	file.close();


func addToDictionnary(key : String, address : String):
	ipDictionnary[key] = address;
	var file : File = File.new();
	file.open(serversFile, File.WRITE);
	file.store_var(ipDictionnary);
	file.close();
