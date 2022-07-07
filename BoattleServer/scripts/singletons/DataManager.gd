extends Node

var playersDataFile : String = "res://data/playersData.json";
var playersPasswordFile : String = "res://data/playersPasswords.json"
var playersShipsStatsFile : String = "res://data/playersShipsStats.json"
var playersDatasDictionary : Dictionary;
var connectedPlayersDictionary : Dictionary;
var playersPasswordsDictionary : Dictionary;
var playerShipsStatsDictionary : Dictionary;

func _ready() -> void:
	loadPlayersDatas();
	loadPlayersPasswords();
	loadPlayersShipsStats();



func savePlayersDatas() -> void:
	var file : File = File.new();
	var error = file.open(playersDataFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersDatasDictionary));
	file.close();

func loadPlayersDatas() -> void:
	var file : File = File.new();
	if not file.file_exists(playersDataFile):
		savePlayersDatas();
		return;
	var error = file.open(playersDataFile, File.READ);
	printError(error);
	playersDatasDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func saveDatasOfAPlayer(playerName : String, position : Vector2) -> void:
	playersDatasDictionary[playerName] = {"posX" : position.x, "posY" : position.y}
	savePlayersDatas();



func savePlayersPasswords():
	var file : File = File.new();
	var error = file.open(playersPasswordFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersPasswordsDictionary));
	file.close();

func loadPlayersPasswords():
	var file : File = File.new();
	if not file.file_exists(playersPasswordFile):
		savePlayersPasswords();
		return;
	var error = file.open(playersPasswordFile, File.READ);
	printError(error);
	playersPasswordsDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func savePasswordsForPlayer(password : String, salt : String, playerName : String) -> void:
	playersPasswordsDictionary[playerName] = {"password" : password, "salt" : salt};
	savePlayersPasswords();



func savePlayersShipsStats():
	var file : File = File.new();
	var error = file.open(playersShipsStatsFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playerShipsStatsDictionary));
	file.close();

func loadPlayersShipsStats():
	var file : File = File.new();
	if not file.file_exists(playersShipsStatsFile):
		savePlayersShipsStats();
		return;
	var error = file.open(playersShipsStatsFile, File.READ);
	printError(error);
	playerShipsStatsDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func createShipStatsForPlayer(playerName : String):
	playerShipsStatsDictionary[playerName] = {"viewRange" : 1.5, "moveRange" : 0.7, "shootRange" : 1.6};
	savePlayersShipsStats();

func saveShipsStatsForPlayer(playerName : String, viewRange : float, moveRange : float, shootRange : float) -> void:
	playerShipsStatsDictionary[playerName] = {"viewRange" : viewRange, "moveRange" : moveRange, "shootRange" : shootRange};
	savePlayersShipsStats();


func playerConnected(playerId : int, playerName : String) -> void:
	connectedPlayersDictionary[playerId] = playerName;

func playerDisconnected(playerId : int) -> void:
	connectedPlayersDictionary.erase(playerId);



func printError(error) -> void:
	if error != 0:
		print("ERROR: ", error);
