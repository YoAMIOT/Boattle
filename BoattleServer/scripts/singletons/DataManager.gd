extends Node

var playersDataFile : String = "res://data/playersData.json";
var playersPasswordFile : String = "res://data/playersPasswords.json"
var playersDatas : Dictionary;
var connectedPlayersDictionnary : Dictionary;
var playersPasswords : Dictionary;

func _ready() -> void:
	loadPlayersDatas();
	loadPlayersPasswords();



func savePlayersDatas() -> void:
	var file : File = File.new();
	var error = file.open(playersDataFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersDatas));
	file.close()

func loadPlayersDatas() -> void:
	var file : File = File.new();
	if not file.file_exists(playersDataFile):
		savePlayersDatas();
		return;
	var error = file.open(playersDataFile, File.READ);
	printError(error);
	playersDatas = JSON.parse(file.get_as_text()).result;
	file.close();

func saveDatasOfAPlayer(playerName : String, position : Vector2) -> void:
	playersDatas[playerName] = {"posX" : position.x, "posY" : position.y}
	savePlayersDatas();

func savePlayersPasswords():
	var file : File = File.new();
	var error = file.open(playersPasswordFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersPasswords));
	file.close()

func loadPlayersPasswords():
	var file : File = File.new();
	if not file.file_exists(playersPasswordFile):
		savePlayersPasswords();
		return;
	var error = file.open(playersPasswordFile, File.READ);
	printError(error);
	playersPasswords = JSON.parse(file.get_as_text()).result;
	file.close();

func savePasswordsForPlayer(password : String, salt : String, playerName : String) -> void:
	playersPasswords[playerName] = {"password" : password, "salt" : salt};
	savePlayersPasswords();




func playerConnected(playerId : int, playerName : String) -> void:
	connectedPlayersDictionnary[playerId] = playerName;

func playerDisconnected(playerId : int) -> void:
	connectedPlayersDictionnary.erase(playerId);



func printError(error) -> void:
	if error != 0:
		print("ERROR: ", error);
